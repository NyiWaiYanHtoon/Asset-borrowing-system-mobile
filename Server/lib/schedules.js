const scheduler = require('node-schedule');
const con = require('../config/db');

const timeoutjob = scheduler.scheduleJob('* 18 * * *', () => {
    con.query(
        "SELECT id, asset_id FROM asset_transaction WHERE validated_date < CURDATE() AND status = ?", ['approved'], (err, result) => {
            if (err) {
                console.log(err);
            } else {
                console.log("Updated Rows:", result);
                const assetIds = result.map(row => row.asset_id);
                const transactionIds = result.map(row => row.id);
                
                //update assets
                con.query("UPDATE assets SET status= ? WHERE id in (?)", ['available', assetIds], (aError, aResults)=>{
                    if(aError){
                        console.log(aError);
                    }else{
                        //update transaction
                        con.query("UPDATE asset_transaction SET status= ? WHERE id in (?)", ['timeout', transactionIds], (tError, tREsults)=>{
                            if(tError){
                                console.log(tError);
                            }else{
                                console.log("timeout scheduling success");
                                console.log(tREsults);
                            }
                        })
                    }
                })
            }
        }
    );
});

const overduejob = scheduler.scheduleJob('0 1 * * *', () => {
    con.query("UPDATE asset_transaction SET status= ? WHERE expected_return_date< CURDATE() AND status = ?", ['overdue', 'holding'], (err, results)=>{
        if(err){
            console.log(err);
        }else{
            console.log("Overdue scheduling Success");
            console.log(results);
        }
    });
});

module.exports = {
    timeoutjob,
    overduejob
}