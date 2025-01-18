#!/usr/bin/env node

const fs = require('fs');

function safeBase64Decode(str) {
  try {
    return Buffer.from(str, 'base64').toString('utf-8');
  } catch (error) {
    console.error('Base64 Decode Error:', error);
    return str;
  }
}

function isBase64(str) {
  try {
    return Buffer.from(str, 'base64').toString('base64') === str;
  } catch {
    return false;
  }
}

function decodeUrlParams(input, additionalBase64Params = []) {
  const result = {};
  
  try {
    const url = new URL(`http://dummy.com${input.startsWith('/') ? input : '/' + input}`);
    const params = new URLSearchParams(url.search);
    
    for (const [key, value] of params.entries()) {
      let decodedValue = value;
      
      // Decode URI-encoded values first
      try {
        decodedValue = decodeURIComponent(decodedValue);
      } catch {}
      
      // Special handling for base64 decoding
      if (
        (key === 'state') || 
        (key.includes('token') || key.includes('jwt')) || 
        additionalBase64Params.includes(key)
      ) {
        if (isBase64(decodedValue)) {
          try {
            const decodedBase64 = safeBase64Decode(decodedValue);
            decodedValue = JSON.parse(decodedBase64);
          } catch (parseError) {
            console.error(`Error parsing ${key}:`, parseError);
            decodedValue = decodedBase64;
          }
        }
      }
      
      result[key] = decodedValue;
    }
  } catch (error) {
    console.error('Error processing URL:', error);
  }
  
  return result;
}

// Main execution
const encodedUrl = process.argv[2];
const additionalBase64Params = process.argv.slice(3);

if (!encodedUrl) {
  console.error('Please provide an encoded URL');
  process.exit(1);
}

const decodedParams = decodeUrlParams(encodedUrl, additionalBase64Params);
console.log(JSON.stringify(decodedParams, null, 2));
