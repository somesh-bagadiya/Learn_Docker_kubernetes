import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from './App';

// Mock the UrlShortener component
jest.mock('./components/UrlShortener', () => {
  return function MockUrlShortener() {
    return <div data-testid="url-shortener">URL Shortener Component</div>;
  };
});

describe('App Component', () => {
  test('renders main heading', () => {
    render(<App />);
    const heading = screen.getByRole('heading', { name: /shortly/i });
    expect(heading).toBeInTheDocument();
  });

  test('renders tagline', () => {
    render(<App />);
    const tagline = screen.getByText(/simple and fast url shortener/i);
    expect(tagline).toBeInTheDocument();
  });

  test('renders UrlShortener component', () => {
    render(<App />);
    const urlShortener = screen.getByTestId('url-shortener');
    expect(urlShortener).toBeInTheDocument();
  });

  test('renders footer', () => {
    render(<App />);
    const footer = screen.getByText(/built with react \+ fastapi \+ redis/i);
    expect(footer).toBeInTheDocument();
  });

  test('has correct main structure', () => {
    render(<App />);
    
    const header = screen.getByRole('banner');
    const main = screen.getByRole('main');
    const footer = screen.getByRole('contentinfo');
    
    expect(header).toBeInTheDocument();
    expect(main).toBeInTheDocument();
    expect(footer).toBeInTheDocument();
  });
}); 