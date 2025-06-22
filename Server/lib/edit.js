const con = require('../config/db');
const jwt = require('jsonwebtoken');
var editProfile= (id, newName, newEmail, newId, photoUrl, res)=>{
   con.query("UPDATE users SET name= ?, email= ?, student_id= ?, profile_pic = ? WHERE id= ?;",[newName, newEmail, newId, photoUrl, id], (err,result)=>{
     if(err) {
        console.log(err);
        return res.status(500).send("sql error")
     }
     else if(result.affectedRows!=1) {
        console.log(result.affectedRows);
        return res.status(400).send("update fail");
     }
     else {
        con.query("SELECT * FROM users WHERE id= ?;", [id], (err, result)=>{
            if(err)console.log(err);
            else{
                const payload = { 'uid': result[0]["id"], 'username': result[0]["name"], 'email': result[0]['email'],'role': result[0]["type_id"], 'profile_pic': result[0]["profile_pic"], 'student_id': result[0]["student_id"] };
                const token = jwt.sign(payload, process.env.JWT_KEY, { expiresIn: '1d' });
                res.status(200).json(token);
            }
        })
     }
   })
}
var editAsset= (id, newName, newType, newStatus, newDes, photoUrl, res)=>{
   con.query("UPDATE assets SET name= ?, type_id= ?, status= ?, description= ?, image_url= ? WHERE id= ?;",[newName, newType, newStatus, newDes, photoUrl, id], (err,result)=>{
     if(err) {
        console.log(err);
        return res.status(500).send("sql error")
     }
     else if(result.affectedRows!=1) {
        console.log(result.affectedRows);
        return res.status(400).send("update fail");
     }
     else res.status(200).send("Asset updated");
   })
}
var returnItem= (asset_id, transaction_id, staff_id, formattedDate, res)=>{
   con.query("UPDATE assets SET status = ? WHERE id = ?", ["available", asset_id], (err, result) => {
      if (err) {
          console.error(err);
          return res.status(500).send("Server error");
      }
      con.query("UPDATE asset_transaction SET status = ?, receiver_id= ?, returned_date= ? WHERE id = ?", ["returned", staff_id, formattedDate, transaction_id], (err, result) => {
          if (err) {
              console.error(err);
              return res.status(500).send("Server error");
          }
          return res.status(200).send("Return successful");
      });
  });
}
var takeoutItem= (asset_id, transaction_id, staff_id, formattedDate, formattedNextWeek, res)=>{
    con.query("UPDATE assets SET status = ? WHERE id = ?", ["borrowed", asset_id], (err, result) => {
       if (err) {
           console.error(err);
           return res.status(500).send("Server error");
       }
       con.query("UPDATE asset_transaction SET status = ?, issued_by_id= ?, borrow_date= ?, expected_return_date= ? WHERE id = ?", ["holding", staff_id, formattedDate, formattedNextWeek, transaction_id], (err, result) => {
           if (err) {
               console.error(err);
               return res.status(500).send("Server error");
           }
           return res.status(200).send("takeout successful");
       });
   });
 }
var cancelItem= (transaction_id, res)=>{
        con.query("UPDATE asset_transaction SET status = ? WHERE id = ?", ["cancelled", transaction_id], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).send("Server error");
            }
            else if(result.affectedRows!=1) return res.status(400).send("no transaction found");
            return res.status(200).send("Request had been Cancelled ");
        });
}
var approveItem= (transaction_id, asset_id, lecturer_id, formattedDate, res)=>{
    con.query("UPDATE assets SET status = ? WHERE id = ?", ["waiting", asset_id], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Server error");
        }
        con.query("UPDATE asset_transaction SET status = ?, validator_id= ?, validated_date= ? WHERE id = ?", ["approved", lecturer_id, formattedDate, transaction_id], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).send("Server error");
            }
            else if(result.affectedRows!=1) return res.status(400).send("no transaction found");
            return res.status(200).send("approve successful");
        });
    });
}
var rejectItem= (transaction_id, asset_id, lecturer_id, formattedDate, res)=>{
    con.query("UPDATE assets SET status = ? WHERE id = ?", ["available", asset_id], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Server error");
        }
        con.query("UPDATE asset_transaction SET status = ?, validator_id= ?, validated_date= ? WHERE id = ?", ["disapproved", lecturer_id, formattedDate, transaction_id], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).send("Server error");
            }
            else if(result.affectedRows!=1) return res.status(400).send("no transaction found");
            return res.status(200).send("disapprove successful");
        });
    });
}

module.exports={
    editProfile,
    editAsset,
    returnItem,
    takeoutItem,
    cancelItem,
    approveItem,
    rejectItem
}

