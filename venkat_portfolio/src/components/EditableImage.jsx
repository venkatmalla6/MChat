

import { useState, useEffect, useCallback } from 'react';
import { Camera, Trash2, Upload, X, Check } from 'lucide-react';
import PropTypes from 'prop-types';
import { storage } from '../config/firebase'; // Kept if needed elsewhere, but strictly we could remove it from here if not used.
// import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'; // Removed unused imports
import Cropper from 'react-easy-crop';
import getCroppedImg from '../utils/canvasUtils';

const EditableImage = ({
    src,
    onSave,
    onDelete,
    alt = 'Editable image',
    className = '',
    storagePath = 'uploads'
}) => {
    const [uploading, setUploading] = useState(false);
    const [preview, setPreview] = useState(src);

    // Crop State
    const [imageSrc, setImageSrc] = useState(null);
    const [crop, setCrop] = useState({ x: 0, y: 0 });
    const [zoom, setZoom] = useState(1);
    const [croppedAreaPixels, setCroppedAreaPixels] = useState(null);
    const [isCropping, setIsCropping] = useState(false);

    useEffect(() => {
        setPreview(src);
    }, [src]);


    const handleFileChange = async (e) => {
        if (e.target.files && e.target.files.length > 0) {
            const file = e.target.files[0];

            // Limit file size to 10MB
            if (file.size > 10 * 1024 * 1024) {
                alert('File size must be less than 10MB');
                return;
            }

            const reader = new FileReader();
            reader.addEventListener('load', () => {
                setImageSrc(reader.result);
                setIsCropping(true);
            });
            reader.readAsDataURL(file);
        }
    };

    const onCropComplete = useCallback((croppedArea, croppedAreaPixels) => {
        setCroppedAreaPixels(croppedAreaPixels);
    }, []);

    const showCroppedImage = useCallback(async () => {
        console.log("Starting crop and save process (Direct Base64)...");
        try {
            setUploading(true);
            console.log("Generating cropped image blob...");
            const croppedImageBlob = await getCroppedImg(
                imageSrc,
                croppedAreaPixels
            );

            if (!croppedImageBlob) {
                throw new Error("Failed to generate image blob");
            }

            console.log("Converting to Base64...");
            const reader = new FileReader();
            reader.onloadend = () => {
                const base64String = reader.result;
                console.log("Base64 generated. Saving...");
                setPreview(base64String);
                onSave(base64String);
                setIsCropping(false);
                setImageSrc(null);
                console.log("Image saved successfully.");
                setUploading(false);
            };
            reader.onerror = (err) => {
                console.error("FileReader error:", err);
                setUploading(false);
                alert("Failed to process image.");
            };
            reader.readAsDataURL(croppedImageBlob);

        } catch (e) {
            console.error("Error in showCroppedImage:", e);
            alert("Upload failed: " + (e.message || e));
            setUploading(false);
        }
    }, [imageSrc, croppedAreaPixels, onSave]);

    const handleCancelCrop = () => {
        setIsCropping(false);
        setImageSrc(null);
    };

    const handleDelete = (e) => {
        e.stopPropagation();
        if (window.confirm('Are you sure you want to remove this image?')) {
            setPreview(null);
            onDelete();
        }
    };

    return (
        <div className={`editable-image-container ${className}`} style={{ position: 'relative', display: 'inline-block' }}>
            {preview ? (
                <>
                    <img src={preview} alt={alt} className={className} style={{ display: 'block' }} />

                    {/* Hover Overlay for Delete */}
                    <div className="image-overlay" style={{
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        width: '100%',
                        height: '100%',
                        background: 'rgba(0,0,0,0.3)',
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        gap: '10px',
                        opacity: 0,
                        transition: 'opacity 0.2s',
                        borderRadius: 'inherit'
                    }}
                        onMouseEnter={(e) => e.currentTarget.style.opacity = 1}
                        onMouseLeave={(e) => e.currentTarget.style.opacity = 0}
                    >
                        {onDelete && (
                            <button onClick={handleDelete} className="btn-icon" title="Remove Photo" style={{
                                cursor: 'pointer',
                                color: '#ff4d4f',
                                background: 'white',
                                padding: '10px',
                                borderRadius: '50%',
                                border: 'none',
                                boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
                            }}>
                                <Trash2 size={20} />
                            </button>
                        )}
                    </div>

                    {/* Always Visible Edit Button */}
                    <label className="edit-btn-floating" style={{
                        position: 'absolute',
                        bottom: '10px',
                        right: '10px',
                        background: 'var(--primary-color, #2563eb)',
                        color: 'white',
                        padding: '10px',
                        borderRadius: '50%',
                        cursor: 'pointer',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        zIndex: 10,
                        transition: 'transform 0.2s'
                    }}
                        onMouseEnter={(e) => e.currentTarget.style.transform = 'scale(1.1)'}
                        onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}
                        title="Change Photo"
                    >
                        <Camera size={20} />
                        <input type="file" onChange={handleFileChange} style={{ display: 'none' }} accept="image/*" />
                    </label>
                </>
            ) : (
                <div className={`${className} placeholder-image`} style={{
                    background: '#f0f0f0',
                    display: 'flex',
                    flexDirection: 'column',
                    justifyContent: 'center',
                    alignItems: 'center',
                    color: '#999',
                    border: '2px dashed #ccc',
                    minHeight: '200px',
                    minWidth: '200px',
                    position: 'relative'
                }}>
                    <Upload size={32} style={{ marginBottom: '8px' }} />
                    {uploading ? 'Uploading...' : 'Upload Image'}
                    <input type="file" onChange={handleFileChange} style={{ opacity: 0, position: 'absolute', inset: 0, cursor: 'pointer' }} accept="image/*" />
                </div>
            )}

            {/* Crop Modal */}
            {isCropping && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    zIndex: 9999,
                    background: 'rgba(0,0,0,0.85)',
                    display: 'flex',
                    flexDirection: 'column',
                    padding: '20px'
                }}>
                    <div style={{ position: 'relative', flex: 1, marginBottom: '20px' }}>
                        <Cropper
                            image={imageSrc}
                            crop={crop}
                            zoom={zoom}
                            aspect={1}
                            onCropChange={setCrop}
                            onCropComplete={onCropComplete}
                            onZoomChange={setZoom}
                        />
                    </div>
                    <div style={{
                        display: 'flex',
                        justifyContent: 'center',
                        gap: '20px',
                        padding: '20px',
                        background: 'white',
                        borderRadius: '12px'
                    }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <label>Zoom</label>
                            <input
                                type="range"
                                value={zoom}
                                min={1}
                                max={3}
                                step={0.1}
                                aria-labelledby="Zoom"
                                onChange={(e) => setZoom(e.target.value)}
                                className="zoom-range"
                            />
                        </div>
                        <button
                            onClick={handleCancelCrop}
                            style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: '5px',
                                padding: '8px 16px',
                                border: '1px solid #ccc',
                                borderRadius: '6px',
                                background: 'white',
                                cursor: 'pointer'
                            }}
                        >
                            <X size={16} /> Cancel
                        </button>
                        <button
                            onClick={showCroppedImage}
                            disabled={uploading}
                            style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: '5px',
                                padding: '8px 16px',
                                border: 'none',
                                borderRadius: '6px',
                                background: 'var(--primary-color, #2563eb)',
                                color: 'white',
                                cursor: 'pointer',
                                opacity: uploading ? 0.7 : 1
                            }}
                        >
                            {uploading ? <div className="spinner-small" /> : <Check size={16} />}
                            {uploading ? 'Saving...' : 'Save & Upload'}
                        </button>
                    </div>
                </div>
            )}

            {uploading && !isCropping && (
                <div style={{ position: 'absolute', inset: 0, background: 'rgba(255,255,255,0.7)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 20, borderRadius: 'inherit' }}>
                    <div className="spinner"></div>
                </div>
            )}
        </div>
    );
};

EditableImage.propTypes = {
    src: PropTypes.string,
    onSave: PropTypes.func.isRequired,
    onDelete: PropTypes.func,
    alt: PropTypes.string,
    className: PropTypes.string,
    storagePath: PropTypes.string
};

export default EditableImage;
