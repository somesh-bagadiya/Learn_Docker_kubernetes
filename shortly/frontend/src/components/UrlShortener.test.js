import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import axios from 'axios';
import UrlShortener from './UrlShortener';

// Mock axios
jest.mock('axios');
const mockedAxios = axios;

// Mock clipboard API
Object.assign(navigator, {
  clipboard: {
    writeText: jest.fn(() => Promise.resolve()),
  },
});

// Mock window.open
global.open = jest.fn();

describe('UrlShortener Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders form elements correctly', () => {
    render(<UrlShortener />);
    
    const input = screen.getByPlaceholderText(/enter a url to shorten/i);
    const button = screen.getByRole('button', { name: /shorten/i });
    
    expect(input).toBeInTheDocument();
    expect(button).toBeInTheDocument();
    expect(button).toBeDisabled();
  });

  test('enables submit button when URL is entered', async () => {
    const user = userEvent.setup();
    render(<UrlShortener />);
    
    const input = screen.getByPlaceholderText(/enter a url to shorten/i);
    const button = screen.getByRole('button', { name: /shorten/i });
    
    await user.type(input, 'example.com');
    
    expect(button).not.toBeDisabled();
  });

  test('shows validation error for invalid URL', async () => {
    const user = userEvent.setup();
    render(<UrlShortener />);
    
    const input = screen.getByPlaceholderText(/enter a url to shorten/i);
    const button = screen.getByRole('button', { name: /shorten/i });
    
    await user.type(input, 'invalid-url');
    await user.click(button);
    
    const errorMessage = screen.getByText(/please enter a valid url/i);
    expect(errorMessage).toBeInTheDocument();
  });

  test('successfully shortens URL', async () => {
    const user = userEvent.setup();
    const mockResponse = {
      data: { short_code: 'abc123' }
    };
    mockedAxios.post.mockResolvedValueOnce(mockResponse);
    
    render(<UrlShortener />);
    
    const input = screen.getByPlaceholderText(/enter a url to shorten/i);
    const button = screen.getByRole('button', { name: /shorten/i });
    
    await user.type(input, 'example.com');
    await user.click(button);
    
    await waitFor(() => {
      expect(mockedAxios.post).toHaveBeenCalledWith('/shorten', {
        url: 'https://example.com'
      });
    });
    
    await waitFor(() => {
      const resultContainer = screen.getByText(/your shortened url/i);
      expect(resultContainer).toBeInTheDocument();
    });
  });

  test('handles API error gracefully', async () => {
    const user = userEvent.setup();
    const mockError = {
      response: {
        data: { detail: 'Invalid URL provided' }
      }
    };
    mockedAxios.post.mockRejectedValueOnce(mockError);
    
    render(<UrlShortener />);
    
    const input = screen.getByPlaceholderText(/enter a url to shorten/i);
    const button = screen.getByRole('button', { name: /shorten/i });
    
    await user.type(input, 'example.com');
    await user.click(button);
    
    await waitFor(() => {
      const errorMessage = screen.getByText(/invalid url provided/i);
      expect(errorMessage).toBeInTheDocument();
    });
  });
}); 