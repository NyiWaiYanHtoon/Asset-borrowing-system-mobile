const con = require('../config/db');
var addAsset = (newName, newType, newStatus, newDes, photoUrl, res) => {
    con.query("INSERT INTO assets (name, type_id, status, description, image_url) VALUES( ?, ?, ?, ?, ?)", [newName, newType, newStatus, newDes, photoUrl], (err, result) => {
        if (err) {
            console.log(err);
            return res.status(500).send("sql error");
        } else if (result.affectedRows != 1) {
            console.log(result.affectedRows);
            return res.status(400).send("update fail");
        }
        else res.status(200).send("Asset Added");
    })
}
var borrowItem = (asset_id, student_id, remark, borrow_date, expected_return_date, res) => {
    con.query("SELECT * FROM asset_transaction WHERE borrower_id= ? AND DATE(booked_date) = CURDATE();", [student_id], (err, result) => {
        if (err) {
            console.log(err);
            return res.status(500).send("sql error");
        } else if (result.length != 0) {
            return res.status(400).send("Borrow limit reached");
        }
        else {
            let sql = `INSERT INTO asset_transaction (asset_id, borrower_id, status, remark, booked_date, expected_return_date) VALUES (?, ?, ?, ?, ?, ?)`;
            con.query(sql, [asset_id, student_id, "pending", remark, borrow_date, expected_return_date], (err, result) => {
                if (err) {
                    console.log(err);
                    return res.status(500).send("sql error");
                }else res.status(200).send("Borrow Successful");
            })
        }
    })
}
module.exports = {
    addAsset,
    borrowItem
}