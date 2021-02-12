/// npm install --save stream-chat
const StreamChat = require('stream-chat').StreamChat;

const apiKey = 'zr8g7ngszfqs';
const apiSecret = '7jp97vwqbrxzh2n9xj8am9c9u4424s8uzwy7trpn5rqcxzy8qs2epvjy2f443hd8';

exports.generateToken = function(idUser, doneCallback) {
    const client = new StreamChat(apiKey, apiSecret);
    const token = client.createToken(idUser);

    doneCallback(token);
};