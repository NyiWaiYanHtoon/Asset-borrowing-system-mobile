const optGenerator = require('otp-generator');
const crypto = require('crypto');
const key = 'test123';
const emailservices = require('./emailer');

function sendOTP(params, res) {
    let hash, expires;// need to be global, to send inside callback function
    try {
        const otp = optGenerator.generate(
            4, {
            digits: true,
            lowerCaseAlphabets: false,
            upperCaseAlphabets: false,
            specialChars: false
        }
        );

        const ttl = 5 * 6 * 1000; // 5 min expires
        expires = Date.now() + ttl;
        const data = `${params.email}.${otp}.${expires}`;
        hash = crypto.createHmac('sha256', key).update(data).digest("hex");
        var otpMessage = `<p style="font-family: Arial, sans-serif; font-size: 16px; color: #333;">
        Please enter: 
        <span style="border: 1px solid #ccc; padding: 4px; font-size: 14px; border-radius: 4px; display: inline-block;">
        ${otp}
        </span> to register your account
        </p>`;
    } catch (err) {
        console.log(err);
        return res.status(500).send("Error creating otp");
    }
    emailservices.sendEmail({
        email: params.email,
        subject: params.subject,
        html: otpMessage
    }, (message) => {// callback function
        if (message == "Invalid email address") {
            return res.status(400).send(message);
        } else if (message == "Error sending email") {
            return res.status(500).send(message);
        }else if(message== "Email already used"){
            return res.status(400).send(message);
        }
        return res.status(200).json({
            hash: hash,
            expires: expires,
        });
    })
}

async function verifyOTP(params, res) {
    //email= userinputted email, otp= userinputted otp
    let { hash, expires, email, otp } = params;
    if (Date.now() > expires) {
        return res.status(400).send('OTP expired');
    }
    
    let data = `${email}.${otp}.${expires}`;
    let newCalcilatedHash = crypto.createHmac('sha256', key).update(data).digest('hex');

    if (newCalcilatedHash === hash) {
        return res.status(200).send("Success");
    }
    return res.status(400).send('Invalid otp');
}

module.exports = {
    sendOTP,
    verifyOTP
}