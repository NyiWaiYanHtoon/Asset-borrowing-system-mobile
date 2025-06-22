// ignore_for_file: prefer_if_null_operators

import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:flutter/material.dart';

class AssetCard extends StatelessWidget {
  final String asset_name;
  final String type_string;
  final String status;
  final String img_string;
  bool edit_button;
  bool disable_button;
  bool request_button;
  bool detail_button;
  Color? status_color;
  Icon? type_icon;
  Function()? editOnPressed;
  Function()? disableOnPressed;
  Function()? requestOnPressed;
  Function()? detailOnPressed;

  AssetCard(
      {required this.asset_name,
      required this.type_string,
      required this.status,
      required this.img_string,
      this.edit_button = false,
      this.disable_button = false,
      this.request_button = false,
      this.detail_button = false,
      this.editOnPressed,
      this.disableOnPressed,
      this.requestOnPressed,
      this.detailOnPressed});

  @override
  Widget build(BuildContext context) {
    // Assign status colors based on the status value
    switch (status) {
      case "available":
        status_color = Colors.green;
        break;
      case "waiting":
        status_color = Colors.yellow[800];
        break;
      case "disabled":
        status_color = Colors.grey[800];
        break;
      case "borrowed":
        status_color = Colors.red;
        break;
      default:
        status_color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
            child: img_string.startsWith('http')
                ? Image.network(
                    img_string,
                    fit: BoxFit.cover,
                    height: 130,
                    width: 150,
                  )
                : Image.asset(
                    img_string,
                    fit: BoxFit.cover,
                    height: 130,
                    width: 150,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.category, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        type_string,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.grey, height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: status_color!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: status_color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (edit_button)
                              ElevatedButton(
                                onPressed: editOnPressed ?? () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: const Color(0xFF003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (disable_button)
                              ElevatedButton(
                                onPressed: disableOnPressed == null
                                    ? () {}
                                    : disableOnPressed,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Disable',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (request_button && status == "available")
                              ElevatedButton(
                                onPressed: requestOnPressed ?? () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: const Color(0xFF003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Request',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (detail_button)
                              ElevatedButton(
                                onPressed: detailOnPressed == null
                                    ? () {}
                                    : detailOnPressed,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: const Color(0xFF003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'View Detail',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String asset_name;
  final String type_string;
  final String img_string;
  final String status;
  final String person_name;
  final String person_pic_string;
  String date_1;
  String date_2;
  Color? status_color;
  Icon? type_icon;
  bool approve_button;
  bool reject_button;
  bool takeout_button;
  bool return_button;
  bool cancel_button;
  final double size;
  String date_label_1;
  String date_label_2;
  Function()? approveOnPressed;
  Function()? rejectOnPressed;
  Function()? takeoutOnPressed;
  Function()? returnOnPressed;
  Function()? cancelOnPressed;

  TransactionCard({
    required this.asset_name,
    required this.type_string,
    required this.img_string,
    required this.size,
    this.person_name = "Default",
    this.person_pic_string = "Default",
    this.status = "Default",
    this.date_1 = "Default",
    this.date_2 = "Default",
    this.approve_button = false,
    this.reject_button = false,
    this.takeout_button = false,
    this.return_button = false,
    this.cancel_button = false,
    this.date_label_1 = "Default",
    this.date_label_2 = "Default",
    this.approveOnPressed,
    this.rejectOnPressed,
    this.takeoutOnPressed,
    this.returnOnPressed,
    this.cancelOnPressed,
  });
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case "approved":
        status_color = Colors.green;
        break;
      case "returned":
        status_color = Colors.blue;
        break;
      case "pending":
      case "holding":
        status_color = Colors.yellow[800];
        break;
      case "disapproved":
        status_color = Colors.red[800];
        break;
      case "cancelled":
        status_color = Colors.grey[800];
        break;
      default:
        status_color = Colors.grey;
    }
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(10)),
            child: img_string.startsWith('http')
                ? Image.network(
                    img_string,
                    fit: BoxFit.cover,
                    height: size,
                    width: 150,
                  )
                : Image.asset(
                    img_string,
                    fit: BoxFit.cover,
                    height: size,
                    width: 150,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.category, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        type_string,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.grey, height: 10),
                  if (date_1 != "Default")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date_label_1,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 15),
                            const SizedBox(width: 10),
                            Text(
                              date_1,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (date_2 != "Default")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date_label_2,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 15),
                            const SizedBox(width: 10),
                            Text(
                              date_2,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (date_2 != "Default" || date_1 != "Default")
                    const Divider(thickness: 1, color: Colors.grey, height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (status != "Default")
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: status_color!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: status_color,
                                ),
                              ),
                            ),
                          if (person_name != "Default")
                            Row(
                              children: [
                                ProfilePicture(
                                    img_string: person_pic_string,
                                    onTap: () {},
                                    size: 10),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  person_name,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (approve_button)
                                ElevatedButton(
                                  onPressed: approveOnPressed ?? () {},
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(40, 30),
                                    backgroundColor: const Color(0xFF2457C5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              if (reject_button)
                                ElevatedButton(
                                  onPressed: rejectOnPressed ?? () {},
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(40, 30),
                                    backgroundColor: Colors.red[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              const SizedBox(width: 8),
                            ],
                          )
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (takeout_button)
                              ElevatedButton(
                                onPressed: takeoutOnPressed ?? () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: Colors.orange[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Take Out',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (return_button)
                              ElevatedButton(
                                onPressed: returnOnPressed ?? () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: Colors.green[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Return',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (cancel_button && status == "pending")
                              ElevatedButton(
                                onPressed: cancelOnPressed == null
                                    ? () {}
                                    : cancelOnPressed,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(40, 30),
                                  backgroundColor: Colors.grey[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class profileCard extends StatelessWidget {
  String profileUrl;
  String name;
  String email;
  Function() onPressed;
  profileCard(
      {super.key,
      required this.profileUrl,
      required this.name,
      required this.email,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        color: const Color(0xFF003366),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              ProfilePicture(
                img_string: profileUrl,
                onTap: () {},
                size: 25,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}
