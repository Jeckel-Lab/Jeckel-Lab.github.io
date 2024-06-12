const fp = new Fingerprint({
    canvas: true,
    ie_activex: true,
    screen_resolution: true
});
const hash = fp.get() + '-' + fp.murmurhash3_32_gc(all.join('###'), 31);

const payload = {
    d: (new Date()).toISOString(),
    r: window.location.href,
    f: document.referrer || null,
    w: window.innerWidth,
    h: hash,
    c: 'JLAB-JEKYLL-PRD'
}

const option = {
    method: 'POST',
    headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload),
};

fetch('https://octopus-app-zzeuv.ondigitalocean.app/traffic', { ...option });
// fetch('http://localhost:3000/traffic', { ...option });
