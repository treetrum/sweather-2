const fetch = require("node-fetch");
const sodium = require("tweetsodium");

const encryptValue = (key, value) => {
    const messageBytes = Buffer.from(value);
    const keyBytes = Buffer.from(key, "base64");
    const encryptedBytes = sodium.seal(messageBytes, keyBytes);
    const encrypted = Buffer.from(encryptedBytes).toString("base64");
    return encrypted;
};

const updateToken = async ({ owner, repo, token, secretName, newValue }) => {
    console.log({ owner, repo, token, secretName, newValue });
    const HOST = `https://api.github.com/repos/${owner}/${repo}`;
    const GET_KEY_URL = `${HOST}/actions/secrets/public-key`;
    const UPDATE_SECRET_URL = `${HOST}/actions/secrets/${secretName}`;
    const headers = { Authorization: `Basic ${token}` };
    const keyResponse = await fetch(GET_KEY_URL, { headers }).then((res) =>
        res.json()
    );
    if (!keyResponse.key) {
        console.error(keyResponse);
        return;
    }
    const { key, key_id } = keyResponse;
    const updateBody = {
        key_id,
        encrypted_value: encryptValue(key, newValue),
    };
    console.log(updateBody);
    const updateReponse = await fetch(UPDATE_SECRET_URL, {
        method: "PUT",
        headers,
        body: JSON.stringify(updateBody),
    });
    console.log(`${updateReponse.status} - ${updateReponse.statusText}`);
};

module.exports = updateToken;
