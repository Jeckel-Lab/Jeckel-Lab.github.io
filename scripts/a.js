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

fetch('https://octopus-app-zzeuv.ondigitalocean.app/traffic', { ...option });
