const updateToken = require("./update-token");
const { exec, spawn } = require("child_process");
const dotenv = require("dotenv");
const sodium = require("tweetsodium");
dotenv.config();

console.log("================================================================");
console.log("IMPORTANT");
console.log("Make sure you choose the option to copy the session to clipboard");
console.log("================================================================");

const child = spawn("fastlane", ["spaceauth"], { stdio: "inherit" });

child.on("close", (code) => {
    exec("pbpaste", (error, output) => {
        console.log("Uploading session to github secret");
        updateToken({
            owner: "treetrum",
            repo: "sweather-2",
            token: process.env.GH_PERSONAL_ACCESS_TOKEN,
            secretName: "FASTLANE_SESSION",
            newValue: output,
        });
    });
});
