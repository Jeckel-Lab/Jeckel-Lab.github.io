const option = {
    method: 'POST',
    headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        d: (new Date()).toISOString(),
        r: window.location.href,
        f: document.referrer || null,
        w: window.innerWidth
    }),
};

fetch('http://localhost:3000/traffic', { ...option });
