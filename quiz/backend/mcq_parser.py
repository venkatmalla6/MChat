import os
import re
import json

# Optionally load transformers. We defer it to save memory if regex succeeds.
pipeline = None

def _load_ai_model():
    global pipeline
    if pipeline is None:
        try:
            from transformers import pipeline as hf_pipeline
            print("Loading HuggingFace model (google/flan-t5-small)...")
            pipeline = hf_pipeline("text2text-generation", model="google/flan-t5-small")
        except Exception as e:
            print(f"Error loading local AI model: {e}")
    return pipeline

def generate_mcq_gemini(text: str, api_key: str):
    """
    Use Google Gemini to generate high-quality MCQs.
    """
    try:
        import google.generativeai as genai
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        prompt = f"""Generate a list of multiple choice questions based on this text. 
Format as a JSON list where each object has:
"question": "string",
"options": ["A", "B", "C", "D"],
"answer": "A/B/C/D"

Text: {text[:4000]}
"""
        response = model.generate_content(prompt)
        # Try to find JSON in response
        json_match = re.search(r'\[.*\]', response.text, re.DOTALL)
        if json_match:
            mcqs = json.loads(json_match.group(0))
            return mcqs
        return []
    except Exception as e:
        print(f"Gemini API Error: {e}")
        return []

def parse_mcq_regex(text: str):
    """
    Attempts to parse pre-existing MCQs from text using Regex.
    Returns a list of dictionaries: [{"question": "", "options": [], "answer": ""}]
    """
    mcqs = []
    
    # Heuristic: split by questions (e.g., "1.", "Q1:", "Question 1:")
    question_blocks = re.split(r'(?:^|\n)(?:\d+[\.\)]|Q\d+\:?|Question\s*\d+\:?)\s+', text)
    
    for block in question_blocks:
        block = block.strip()
        if not block:
            continue
            
        # Try to extract options (e.g., "A)", "a.", "(A)")
        # This regex looks for typical option markers
        options_split = re.split(r'(?:^|\n)\s*(?:[A-D][\.\)]|\([A-D]\)|[a-d][\.\)]|\([a-d]\))\s+', block)
        
        if isinstance(options_split, list) and len(options_split) >= 5: # 1 question + at least 4 options
            question = str(options_split[0]).strip()
            
            options: list[str] = []
            for idx in range(1, 5):
                options.append(str(options_split[idx]).strip())
            
            # Find answer if it exists in the remaining text
            remaining_text = ""
            if len(options_split) > 5:
                for idx in range(5, len(options_split)):
                    remaining_text += str(options_split[idx])
            else:
                remaining_text = block
            answer = ""
            
            ans_match = re.search(r'(?:Answer|Ans)[\s\:]+([A-D]|[a-d]|Option\s*[1-4])', remaining_text, re.IGNORECASE)
            if ans_match:
                answer = ans_match.group(1).upper()
            
            # Additional cleanup formatting
            clean_options = [o.split('\n')[0].strip() for o in options]
            
            # Ensure no duplicates and minimum length
            unique_options = list(dict.fromkeys(clean_options))
            if len(unique_options) >= 4:
                mcq_dict: dict[str, str | list[str]] = {
                    "question": question,
                    "options": [unique_options[0], unique_options[1], unique_options[2], unique_options[3]],
                    "answer": answer
                }
                mcqs.append(mcq_dict)

    return mcqs

def generate_mcq_ai(text: str):
    """
    Fallback: Use a local HuggingFace model to generate an MCQ from the text context.
    Since small models struggle with valid JSON arrays, we prompt for a single MCQ format
    and parse it out manually.
    """
    generator = _load_ai_model()
    
    # We truncate text to fit context limits (flan-t5 is 512 tokens usually, roughly 1500 chars)
    context = text[:1500] # type: ignore
    
    prompt = f"""Generate a multiple choice question based on this context. Provide the question, 4 options labeled A, B, C, D, and the correct answer.
Context: {context}
Format:
Question: [question]
A) [option 1]
B) [option 2]
C) [option 3]
D) [option 4]
Answer: [correct letter]
"""

    try:
        result = generator(prompt, max_length=200, do_sample=True, temperature=0.7)
        generated_text = result[0]['generated_text']
        
        # Try to parse the generated output
        q_match = re.search(r'Question:\s*(.+?)(?=A\))', generated_text, re.DOTALL | re.IGNORECASE)
        opt_a = re.search(r'A\)\s*(.+?)(?=B\))', generated_text, re.DOTALL)
        opt_b = re.search(r'B\)\s*(.+?)(?=C\))', generated_text, re.DOTALL)
        opt_c = re.search(r'C\)\s*(.+?)(?=D\))', generated_text, re.DOTALL)
        opt_d = re.search(r'D\)\s*(.+?)(?=Answer:|$)', generated_text, re.DOTALL)
        ans = re.search(r'Answer:\s*([A-D])', generated_text, re.IGNORECASE)
        
        # Strictly verify all regex matches are not None before accessing .group(1)
        if (q_match is not None and 
            opt_a is not None and 
            opt_b is not None and 
            opt_c is not None and 
            opt_d is not None):
            
            options: list[str] = [
                str(opt_a.group(1)).strip(),
                str(opt_b.group(1)).strip(),
                str(opt_c.group(1)).strip(),
                str(opt_d.group(1)).strip()
            ]
            
            # Remove empty options and padding
            valid_options = [o for o in options if o]
            unique_options = list(dict.fromkeys(valid_options))
            
            if len(unique_options) >= 4:
                final_answer = "A"
                if ans is not None:
                    final_answer = str(ans.group(1)).upper()
                    
                return [{
                    "question": str(q_match.group(1)).strip(),
                    "options": [unique_options[0], unique_options[1], unique_options[2], unique_options[3]],
                    "answer": final_answer
                }]
                
        return []
        
    except Exception as e:
        print(f"AI Generation Error: {e}")
        return []

def process_text_into_mcqs(text: str, api_key: str = None):
    """
    Main entry point. 
    1. Try Regex (for existing MCQs).
    2. Try Gemini (if key exists).
    3. Fallback to local AI (flan-t5).
    """
    if not text or not text.strip():
        return []
        
    # 1. Try Regex Parsing (if the document was already a test/quiz format)
    mcqs = parse_mcq_regex(text)
    
    # 2. If regex finds nothing, try Gemini
    if not mcqs and api_key:
        print("Regex found 0 MCQs. Trying Gemini generation...")
        mcqs = generate_mcq_gemini(text, api_key)

    # 3. Fallback to local AI generation
    if not mcqs:
        print("Fallback to local AI generation...")
        mcqs = generate_mcq_ai(text)
        
    # Validation step to ensure min 4 options per question at output level
    valid_mcqs: list[dict[str, str | list[str]]] = []
    for m in mcqs:
        raw_opts = m.get("options", [])
        if isinstance(raw_opts, list) and len(raw_opts) >= 4:
            valid_mcqs.append(m)
            
    return valid_mcqs
