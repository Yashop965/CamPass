const fs = require('fs');
const path = require('path');
const os = require('os');

function getLocalIp() {
    const interfaces = os.networkInterfaces();
    const candidates = [];

    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            // Skip internal (non-127.0.0.1) and non-ipv4 addresses
            if ('IPv4' !== iface.family || iface.internal) {
                continue;
            }
            candidates.push({ name, address: iface.address });
        }
    }

    console.log('🔎 Found interfaces:', candidates);

    // Filter out VirtualBox Host-Only Network (usually 192.168.56.x)
    const valid = candidates.filter(c => !c.address.startsWith('192.168.56.'));

    if (valid.length === 0) return candidates.length > 0 ? candidates[0].address : '127.0.0.1';

    // Prefer Wi-Fi
    const wifi = valid.find(c => c.name.toLowerCase().includes('wi-fi') || c.name.toLowerCase().includes('wlan'));
    if (wifi) return wifi.address;

    return valid[0].address;
}

const configPath = path.join(__dirname, '../../frontend/campass_app/lib/core/config/app_config.dart');
const localIp = getLocalIp();
const newUrl = `http://${localIp}:5000`;

try {
    let content = fs.readFileSync(configPath, 'utf8');

    // Regex to find the development return statement
    // Matches: return 'http://<ip>:5000';
    const regex = /return 'http:\/\/[\d+\.]+:5000';/;

    if (regex.test(content)) {
        content = content.replace(regex, `return '${newUrl}';`);
        fs.writeFileSync(configPath, content);
        console.log(`✅ Updated API URL to: ${newUrl}`);
    } else {
        console.log('⚠️ Could not find development URL pattern in app_config.dart');
        console.log('Expected pattern: return \'http://x.x.x.x:5000\';');
    }
} catch (err) {
    console.error('❌ Error updating app_config.dart:', err.message);
}
