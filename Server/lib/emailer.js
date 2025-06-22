const nodemailer = require('nodemailer');
const con = require('../config/db')

function sendEmail(params, callback) {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(params.email)) {
        return callback("Invalid email address");
    }

    const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: "tunEmailer@gmail.com",
            pass: "fcup upvd zinh wzhw"
        }
    })
    con.query("SELECT * FROM users WHERE email= ?", [params.email], (err, result) => {
        if (err) {
            return callback("Error sending email");
        } else if (result.length != 0) {
            return callback("Email already used");
        } else {
            transporter.sendMail({
                from: "tunEmailer@gmail.com",
                to: params.email,
                subject: params.subject,
                html: params.html
            }, (err, info) => {
                if (err) {
                    console.log(err);
                    return callback("Error sending email");
                } else {
                    return callback("Email sent");
                }
            })
        }
    })
}
module.exports = {
    sendEmail
}
