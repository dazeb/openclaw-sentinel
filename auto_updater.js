const { execSync } = require('child_process');
const fs = require('fs');

function getCurrentVersion() {
    try {
        // Try getting version from CLI
        const version = execSync('openclaw --version', { encoding: 'utf8' }).trim();
        return version;
    } catch (e) {
        console.error("Failed to get local version:", e);
        return null;
    }
}

function getRemoteVersion() {
    try {
        const version = execSync('npm view openclaw@beta version', { encoding: 'utf8' }).trim();
        return version;
    } catch (e) {
        console.error("Failed to get remote version:", e);
        return null;
    }
}

function main() {
    console.log("Checking for OpenClaw updates...");
    
    const current = getCurrentVersion();
    const remote = getRemoteVersion();

    if (!current || !remote) {
        console.error("Could not determine versions.");
        process.exit(1);
    }

    console.log(`Current: ${current}`);
    console.log(`Remote:  ${remote}`);

    if (current === remote) {
        console.log("System is up to date.");
        process.exit(0);
    }

    console.log("Update available! Initiating update sequence...");
    
    // Trigger the gateway update command
    // We use the gateway tool via exec, or just the CLI command
    try {
        // This will trigger the update and restart the gateway
        // The script itself will be killed during restart, which is expected.
        execSync('openclaw gateway update.run', { stdio: 'inherit' });
    } catch (e) {
        console.error("Update failed:", e);
        process.exit(1);
    }
}

main();