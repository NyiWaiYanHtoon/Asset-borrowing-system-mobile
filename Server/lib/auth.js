const con = require('../config/db');
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: '../.env' });

var register = (email, psw, res) => {
    bcrypt.hash(psw, 10, function (err, hash) {
        if (err) return res.status(500).send("Server error");
        else {
            con.query("INSERT INTO users (name, email, psw, student_id, type_id) VALUES( ?, ?, ?, ?, ?)", [`Guest_${email.split('@')[0]}`, email, hash, "", 1], (err, result) => {
                if (err) {
                    return res.status(500).send("Server error");
                } else {
                    return res.status(200).send("Success")
                }
            })
        }
    })
}
var login = (email, psw, res) => {
    con.query("SELECT * FROM users WHERE email= ?", [email], (err, result) => {
        if (err) {
            return res.status(500).send("sql error");
        } else {
            if (result.length != 1) {
                return res.status(400).send("Wrong email");
            } else {
                bcrypt.compare(psw, result[0]["psw"], (err, same) => {
                    if (err) {
                        return res.status(500).send("hash error");
                    } else if (!same) {
                        return res.status(400).send("Wrong Password");
                    } else {
                        const payload = { 'uid': result[0]["id"], 'username': result[0]["name"], 'email': result[0]['email'], 'role': result[0]["type_id"], 'profile_pic': result[0]["profile_pic"], 'student_id': result[0]["student_id"] };
                        const token = jwt.sign(payload, process.env.JWT_KEY, { expiresIn: '1d' });
                        res.status(200).json({ "role": result[0]["type_id"], "token": token });
                    }
                })
            }
        }
    })
}
var authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token == null) return res.sendStatus(401);
    jwt.verify(token, process.env.JWT_KEY, (err, user) => {
        if (err) {
            console.log(err);
            return res.sendStatus(403);
        }
        req.user = user;
        next();
    });
}
module.exports = {
    register,
    login,
    authenticateToken
}