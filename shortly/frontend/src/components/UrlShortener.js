import React, { useState } from 'react';
import axios from 'axios';
import './UrlShortener.css';

const UrlShortener = () => {
  const [url, setUrl] = useState('');
  const [shortUrl, setShortUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [copied, setCopied] = useState(false);

  // URL validation regex
  const urlRegex = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/;

  const validateUrl = (inputUrl) => {
    if (!inputUrl.trim()) {
      return 'Please enter a URL';
    }
    
    // Add protocol if missing
    let validUrl = inputUrl.trim();
    if (!validUrl.startsWith('http://') && !validUrl.startsWith('https://')) {
      validUrl = `https://${validUrl}`;
    }
    
    if (!urlRegex.test(validUrl)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Reset previous states
    setError('');
    setShortUrl('');
    setCopied(false);
    
    // Validate URL
    const validationError = validateUrl(url);
    if (validationError) {
      setError(validationError);
      return;
    }
    
    // Prepare URL with protocol
    let processedUrl = url.trim();
    if (!processedUrl.startsWith('http://') && !processedUrl.startsWith('https://')) {
      processedUrl = `https://${processedUrl}`;
    }
    
    setLoading(true);
    
    try {
      const response = await axios.post('/shorten', {
        url: processedUrl
      });
      
      // Construct full short URL
      const fullShortUrl = `${window.location.origin}/${response.data.short_code}`;
      setShortUrl(fullShortUrl);
    } catch (err) {
      if (err.response) {
        // Server responded with error status
        setError(err.response.data.detail || 'Failed to shorten URL');
      } else if (err.request) {
        // Network error
        setError('Network error. Please check your connection and try again.');
      } else {
        // Other error
        setError('An unexpected error occurred. Please try again.');
      }
      // console.error('Error shortening URL:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(shortUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      // console.error('Failed to copy:', err);
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = shortUrl;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleTestRedirect = () => {
    window.open(shortUrl, '_blank');
  };

  return (
    <div className="url-shortener">
      <form onSubmit={handleSubmit} className="url-form">
        <div className="input-group">
          <input
            type="text"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            placeholder="Enter a URL to shorten (e.g., example.com)"
            className={`url-input ${error ? 'error' : ''}`}
            disabled={loading}
          />
          <button 
            type="submit" 
            className="submit-btn"
            disabled={loading || !url.trim()}
          >
            {loading ? (
              <span className="loading-spinner"></span>
            ) : (
              'Shorten'
            )}
          </button>
        </div>
        
        {error && (
          <div className="error-message">
            <span className="error-icon">⚠️</span>
            {error}
          </div>
        )}
      </form>

      {shortUrl && (
        <div className="result-container">
          <h3>Your shortened URL:</h3>
          <div className="result-url">
            <input
              type="text"
              value={shortUrl}
              readOnly
              className="short-url-display"
            />
            <div className="url-actions">
              <button 
                onClick={handleCopy}
                className={`copy-btn ${copied ? 'copied' : ''}`}
              >
                {copied ? '✓ Copied!' : '📋 Copy'}
              </button>
              <button 
                onClick={handleTestRedirect}
                className="test-btn"
              >
                🔗 Test
              </button>
            </div>
          </div>
          <p className="result-info">
            Click the short URL or use the test button to verify it works!
          </p>
        </div>
      )}
    </div>
  );
};

export default UrlShortener; 