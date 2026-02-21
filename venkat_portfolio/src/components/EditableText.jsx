
import { useState, useRef, useEffect } from 'react';
import { Pencil, Check, X } from 'lucide-react';
import PropTypes from 'prop-types';

const EditableText = ({
    initialValue,
    onSave,
    tagName: Tag = 'div',
    className = '',
    placeholder = 'Click to edit...',
    multiline = false
}) => {
    const [isEditing, setIsEditing] = useState(false);
    const [value, setValue] = useState(initialValue);
    const inputRef = useRef(null);

    useEffect(() => {
        setValue(initialValue);
    }, [initialValue]);

    useEffect(() => {
        if (isEditing && inputRef.current) {
            inputRef.current.focus();
        }
    }, [isEditing]);

    const handleSave = () => {
        setIsEditing(false);
        if (value !== initialValue) {
            onSave(value);
        }
    };

    const handleCancel = () => {
        setIsEditing(false);
        setValue(initialValue);
    };

    const handleKeyDown = (e) => {
        if (e.key === 'Enter' && !multiline) {
            handleSave();
        } else if (e.key === 'Escape') {
            handleCancel();
        }
    };

    if (isEditing) {
        return (
            <div className={`editable-container editing ${className}`} style={{ position: 'relative', display: 'inline-block', width: '100%' }}>
                {multiline ? (
                    <textarea
                        ref={inputRef}
                        value={value}
                        onChange={(e) => setValue(e.target.value)}
                        onBlur={handleSave}
                        onKeyDown={handleKeyDown}
                        className="editable-input"
                        rows={4}
                        style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #ccc' }}
                    />
                ) : (
                    <input
                        ref={inputRef}
                        value={value}
                        onChange={(e) => setValue(e.target.value)}
                        onBlur={handleSave}
                        onKeyDown={handleKeyDown}
                        className="editable-input"
                        style={{ width: '100%', padding: '4px', borderRadius: '4px', border: '1px solid #ccc' }}
                    />
                )}
                <div className="edit-actions" style={{ position: 'absolute', right: 0, top: '-25px', display: 'flex', gap: '4px', background: 'white', border: '1px solid #ddd', borderRadius: '4px', padding: '2px' }}>
                    <button onMouseDown={handleSave} type="button" style={{ color: 'green', border: 'none', background: 'none', cursor: 'pointer' }}><Check size={16} /></button>
                    <button onMouseDown={handleCancel} type="button" style={{ color: 'red', border: 'none', background: 'none', cursor: 'pointer' }}><X size={16} /></button>
                </div>
            </div>
        );
    }

    return (
        <div className={`editable-container ${className}`} style={{ position: 'relative', cursor: 'text' }} onClick={() => setIsEditing(true)}>
            <Tag className="editable-content">
                {value || <span style={{ fontStyle: 'italic', color: '#999' }}>{placeholder}</span>}
                <span className="edit-icon-hover" style={{ marginLeft: '8px', opacity: 0.3 }}><Pencil size={14} /></span>
            </Tag>
        </div>
    );
};

EditableText.propTypes = {
    initialValue: PropTypes.string,
    onSave: PropTypes.func.isRequired,
    tagName: PropTypes.elementType,
    className: PropTypes.string,
    placeholder: PropTypes.string,
    multiline: PropTypes.bool
};

export default EditableText;
