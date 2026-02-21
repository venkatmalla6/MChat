import { useState, useCallback } from 'react';

export const useForm = (initialValues, validate) => {
    const [values, setValues] = useState(initialValues);
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);

    const keypress = useCallback((e) => {
        const { name, value } = e.target;
        setValues({
            ...values,
            [name]: value
        });

        // Real-time validation (optional, can be removed for submit-only validation)
        if (validate) {
            const validationErrors = validate({ ...values, [name]: value });
            setErrors(validationErrors);
        }
    }, [values, validate]);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setValues({
            ...values,
            [name]: value
        });
    };

    const handleSubmit = async (submitCallback) => {
        setIsSubmitting(true);
        const validationErrors = validate ? validate(values) : {};
        setErrors(validationErrors);

        if (Object.keys(validationErrors).length === 0) {
            try {
                await submitCallback();
                setValues(initialValues); // Reset form
            } catch (error) {
                console.error("Submission error", error);
            }
        }
        setIsSubmitting(false);
    };

    return {
        values,
        errors,
        isSubmitting,
        handleChange,
        handleSubmit
    };
};
