import React from 'react';
import UrlShortener from './components/UrlShortener';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Shortly</h1>
        <p>Simple and Fast URL Shortener</p>
      </header>
      <main className="App-main">
        <UrlShortener />
      </main>
      <footer className="App-footer">
        <p>Built with React + FastAPI + Redis</p>
      </footer>
    </div>
  );
}

export default App; 