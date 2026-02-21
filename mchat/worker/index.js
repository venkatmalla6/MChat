// Helper: SHA-256 hash
async function hashPassword(password) {
    const myText = new TextEncoder().encode(password);
    const myDigest = await crypto.subtle.digest({ name: 'SHA-256' }, myText);
    return Array.from(new Uint8Array(myDigest)).map(b => b.toString(16).padStart(2, '0')).join('');
}

// Helper: Send email via Resend
async function sendOTPEmail(apiKey, toEmail, otp) {
    const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            from: 'MChat <onboarding@resend.dev>',
            to: [toEmail],
            subject: 'MChat - Your Password Reset OTP',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 32px; background: #1a202c; color: #e2e8f0; border-radius: 12px;">
                    <h2 style="color: #63b3ed; margin-bottom: 8px;">🔐 Password Reset</h2>
                    <p>Use the OTP below to reset your MChat password. It expires in <strong>10 minutes</strong>.</p>
                    <div style="font-size: 36px; font-weight: bold; letter-spacing: 12px; text-align: center; background: #2d3748; padding: 20px; border-radius: 8px; margin: 24px 0; color: #90cdf4;">
                        ${otp}
                    </div>
                    <p style="color: #a0aec0; font-size: 13px;">If you didn't request this, please ignore this email.</p>
                </div>
            `,
        }),
    });
    return res.ok;
}

export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        const method = request.method;

        // CORS Headers
        const corsHeaders = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
        };

        if (method === "OPTIONS") {
            return new Response(null, { headers: corsHeaders });
        }

        // ─── REGISTER ───────────────────────────────────────────────────────────
        if (url.pathname === "/api/register" && method === "POST") {
            try {
                const { email, password, name } = await request.json();
                if (!email || !password) {
                    return new Response(JSON.stringify({ error: "Email and password required" }), { status: 400, headers: corsHeaders });
                }
                const hashedPassword = await hashPassword(password);
                // Generate unique 6-char Chat ID e.g. MCH4F2A
                const chatId = 'MCH' + Math.random().toString(36).substr(2, 4).toUpperCase();
                const result = await env.DB.prepare(
                    "INSERT INTO users (email, password, name, chat_id) VALUES (?, ?, ?, ?)"
                ).bind(email, hashedPassword, name || email.split('@')[0], chatId).run();

                if (result.success) {
                    return new Response(JSON.stringify({ message: "User registered successfully", chat_id: chatId }), { status: 201, headers: corsHeaders });
                } else {
                    return new Response(JSON.stringify({ error: "Registration failed. Email might be taken." }), { status: 400, headers: corsHeaders });
                }
            } catch (e) {
                if (e.message && e.message.includes('UNIQUE constraint failed')) {
                    return new Response(JSON.stringify({ error: "This email is already registered. Please sign in instead." }), { status: 409, headers: corsHeaders });
                }
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── LOGIN ───────────────────────────────────────────────────────────────
        if (url.pathname === "/api/login" && method === "POST") {
            try {
                const { email, password } = await request.json();
                const hashedPassword = await hashPassword(password);
                const user = await env.DB.prepare(
                    "SELECT * FROM users WHERE email = ? AND password = ?"
                ).bind(email, hashedPassword).first();

                if (user) {
                    // ── Ensure user always has a chat_id ───────────────────────
                    let chatId = user.chat_id;
                    if (!chatId) {
                        // Generate a unique chat_id for older accounts that lack one
                        chatId = 'MCH' + Math.random().toString(36).substr(2, 4).toUpperCase();
                        await env.DB.prepare(
                            "UPDATE users SET chat_id = ? WHERE id = ? AND (chat_id IS NULL OR chat_id = '')"
                        ).bind(chatId, user.id).run();
                    }

                    const token = btoa(JSON.stringify({ id: user.id, email: user.email, exp: Date.now() + 3600000 }));
                    return new Response(JSON.stringify({
                        token,
                        chat_id: chatId,
                        user: { email: user.email, name: user.name || user.email.split('@')[0] }
                    }), { status: 200, headers: corsHeaders });
                } else {
                    return new Response(JSON.stringify({ error: "Invalid credentials" }), { status: 401, headers: corsHeaders });
                }
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── FORGOT PASSWORD: Send OTP ────────────────────────────────────────
        if (url.pathname === "/api/forgot-password" && method === "POST") {
            try {
                const { email } = await request.json();
                if (!email) {
                    return new Response(JSON.stringify({ error: "Email is required" }), { status: 400, headers: corsHeaders });
                }

                // Check user exists
                const user = await env.DB.prepare("SELECT id FROM users WHERE email = ?").bind(email).first();
                if (!user) {
                    return new Response(JSON.stringify({ error: "No account found with that email address." }), { status: 404, headers: corsHeaders });
                }

                // Generate 6-digit OTP
                const otp = Math.floor(100000 + Math.random() * 900000).toString();
                const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

                // Delete old OTPs for this email, then store new one
                await env.DB.prepare("DELETE FROM otp_tokens WHERE email = ?").bind(email).run();
                await env.DB.prepare("INSERT INTO otp_tokens (email, otp, expires_at) VALUES (?, ?, ?)").bind(email, otp, expiresAt).run();

                // Send email
                const sent = await sendOTPEmail(env.RESEND_API_KEY, email, otp);
                if (!sent) {
                    return new Response(JSON.stringify({ error: "Failed to send OTP email. Please try again." }), { status: 500, headers: corsHeaders });
                }

                return new Response(JSON.stringify({ message: "OTP sent to your email." }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── VERIFY OTP & RESET PASSWORD ──────────────────────────────────────
        if (url.pathname === "/api/verify-otp" && method === "POST") {
            try {
                const { email, otp, newPassword } = await request.json();
                if (!email || !otp || !newPassword) {
                    return new Response(JSON.stringify({ error: "Email, OTP, and new password are required" }), { status: 400, headers: corsHeaders });
                }

                // Fetch OTP record
                const record = await env.DB.prepare(
                    "SELECT * FROM otp_tokens WHERE email = ? AND otp = ?"
                ).bind(email, otp).first();

                if (!record) {
                    return new Response(JSON.stringify({ error: "Invalid OTP. Please check and try again." }), { status: 400, headers: corsHeaders });
                }

                if (Date.now() > record.expires_at) {
                    await env.DB.prepare("DELETE FROM otp_tokens WHERE email = ?").bind(email).run();
                    return new Response(JSON.stringify({ error: "OTP has expired. Please request a new one." }), { status: 400, headers: corsHeaders });
                }

                // Hash new password and update
                const hashedPassword = await hashPassword(newPassword);
                await env.DB.prepare("UPDATE users SET password = ? WHERE email = ?").bind(hashedPassword, email).run();

                // Delete used OTP
                await env.DB.prepare("DELETE FROM otp_tokens WHERE email = ?").bind(email).run();

                return new Response(JSON.stringify({ message: "Password reset successfully." }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── GET USER PROFILE ────────────────────────────────────────────────
        if (url.pathname === "/api/user" && method === "GET") {
            const authHeader = request.headers.get("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
            }
            const token = authHeader.split(" ")[1];
            try {
                const payload = JSON.parse(atob(token));
                const user = await env.DB.prepare("SELECT email, name, chat_id, avatar_url, created_at FROM users WHERE id = ?").bind(payload.id).first();
                if (!user) {
                    return new Response(JSON.stringify({ error: "User not found" }), { status: 404, headers: corsHeaders });
                }
                return new Response(JSON.stringify({
                    email: user.email,
                    name: user.name || user.email.split('@')[0],
                    chat_id: user.chat_id || 'N/A',
                    avatar_url: user.avatar_url,
                    joined: user.created_at || new Date().toISOString()
                }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: "Invalid token" }), { status: 401, headers: corsHeaders });
            }
        }

        // ─── LOOKUP USER BY CHAT ID ───────────────────────────────────────────
        if (url.pathname === "/api/user-by-chatid" && method === "GET") {
            const authHeader = request.headers.get("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
            }
            const chatId = url.searchParams.get('chat_id');
            if (!chatId) {
                return new Response(JSON.stringify({ error: "chat_id is required" }), { status: 400, headers: corsHeaders });
            }
            try {
                const user = await env.DB.prepare(
                    "SELECT email, name, chat_id FROM users WHERE chat_id = ?"
                ).bind(chatId.toUpperCase()).first();
                if (!user) {
                    return new Response(JSON.stringify({ error: "No user found with that Chat ID." }), { status: 404, headers: corsHeaders });
                }
                return new Response(JSON.stringify({ email: user.email, name: user.name, chat_id: user.chat_id }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── UNREAD MESSAGE COUNT ─────────────────────────────────────────────────
        if (url.pathname === "/api/messages/unread-count" && method === "GET") {
            const authHeader = request.headers.get("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
            }
            try {
                const token = authHeader.split(" ")[1];
                const payload = JSON.parse(atob(token));
                const myEmail = payload.email;
                // Count messages received by this user in the last 24 hours
                const since = Date.now() - 24 * 60 * 60 * 1000;
                const result = await env.DB.prepare(
                    `SELECT COUNT(*) as count FROM messages WHERE receiver_email = ? AND created_at > ?`
                ).bind(myEmail, since).first();
                return new Response(JSON.stringify({ count: result?.count || 0 }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── GET MESSAGES (DM) ───────────────────────────────────────────────────

        if (url.pathname === "/api/messages" && method === "GET") {
            const authHeader = request.headers.get("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
            }
            const receiverEmail = url.searchParams.get('with');
            if (!receiverEmail) {
                return new Response(JSON.stringify({ error: "'with' query param (receiver email) is required" }), { status: 400, headers: corsHeaders });
            }
            try {
                const token = authHeader.split(" ")[1];
                const payload = JSON.parse(atob(token));
                const myEmail = payload.email;
                // Fetch msgs between the two users in both directions
                const { results } = await env.DB.prepare(
                    `SELECT id, sender_email, sender_name, content, created_at FROM messages
                     WHERE (sender_email = ? AND receiver_email = ?)
                        OR (sender_email = ? AND receiver_email = ?)
                     ORDER BY created_at ASC LIMIT 100`
                ).bind(myEmail, receiverEmail, receiverEmail, myEmail).all();
                return new Response(JSON.stringify({ messages: results }), { status: 200, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        // ─── SEND MESSAGE (DM) ───────────────────────────────────────────────────
        if (url.pathname === "/api/messages" && method === "POST") {
            const authHeader = request.headers.get("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
            }
            try {
                const token = authHeader.split(" ")[1];
                const payload = JSON.parse(atob(token));
                const { content, receiver_email } = await request.json();
                if (!content || !content.trim()) {
                    return new Response(JSON.stringify({ error: "Message cannot be empty" }), { status: 400, headers: corsHeaders });
                }
                if (!receiver_email) {
                    return new Response(JSON.stringify({ error: "receiver_email is required" }), { status: 400, headers: corsHeaders });
                }
                const user = await env.DB.prepare("SELECT name FROM users WHERE id = ?").bind(payload.id).first();
                const senderName = user?.name || payload.email.split('@')[0];
                await env.DB.prepare(
                    "INSERT INTO messages (sender_email, sender_name, content, created_at, receiver_email) VALUES (?, ?, ?, ?, ?)"
                ).bind(payload.email, senderName, content.trim(), Date.now(), receiver_email).run();
                return new Response(JSON.stringify({ message: "Sent" }), { status: 201, headers: corsHeaders });
            } catch (e) {
                return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: corsHeaders });
            }
        }

        return new Response("Not Found", { status: 404, headers: corsHeaders });
    }
};
