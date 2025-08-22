// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

async function triggerLog(logType) {
    const responseDiv = document.getElementById('response');
    responseDiv.innerHTML = '<div class="alert alert-info">Sending request...</div>';
    
    try {
        const response = await fetch(`/api/logging/${logType}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });
        
        if (response.ok) {
            responseDiv.innerHTML = `<div class="alert alert-success">${logType.toUpperCase()} log triggered successfully!</div>`;
        } else {
            responseDiv.innerHTML = `<div class="alert alert-danger">Error: ${response.status} ${response.statusText}</div>`;
        }
    } catch (error) {
        responseDiv.innerHTML = `<div class="alert alert-danger">Network error: ${error.message}</div>`;
    }
}
