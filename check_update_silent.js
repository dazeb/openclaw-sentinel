const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const STATE_FILE = path.join(__dirname, '../memory/heartbeat-state.json');
const CHECK_INTERVAL_MS = 60 * 60 * 1000; // 1 hour

function loadState() {
    if (fs.existsSync(STATE_FILE)) {
        return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
    }
    return { lastChecks: {} };
}

function saveState(state) {
    fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function main() {
    const state = loadState();
    const lastCheck = state.lastChecks?.update || 0;
    const now = Date.now();

    // Throttle check
    if (now - lastCheck < CHECK_INTERVAL_MS) {
        return; // Too soon
    }

    try {
        const current = execSync('openclaw --version', { encoding: 'utf8' }).trim();
        const remote = execSync('npm view openclaw@beta version', { encoding: 'utf8' }).trim();

        state.lastChecks.update = now;
        saveState(state);

        if (current !== remote) {
            console.log(`🚨 **UPDATE DETECTED**\nCurrent: ${current} | New: ${remote}\nInitiating auto-update sequence...`);
            try {
                execSync('openclaw gateway update.run', { stdio: 'inherit' });
            } catch (e) {
                console.error("Update failed:", e);
            }
        }
    } catch (e) {
        // Silent fail to avoid noise
    }
}

main();