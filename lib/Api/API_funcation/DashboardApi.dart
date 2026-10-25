import "dart:convert";
import 'package:flutter/foundation.dart';
// import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:trachcare/Api/Apiurl.dart";
import "package:trachcare/Api/DataStore/Datastore.dart";

class PatientDashBoardApi {
  Future FetchStatus() async {
    var url = "$statusurlpatient?patient_id=${patient_id.toString()}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['Status']) {
          debugPrint(data['data'][0]['patient_id'].toString());
          return data['data'][0];
        } else {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future FetchDetials() async {
    var Data = {"patient_id": patient_id.toString()};
    try {
      final response = await http.post(Uri.parse(getpatientdetialsurl),
          body: jsonEncode(Data));
      // debugPrint(response.body.toString());
      var datas = await FetchStatus();
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        debugPrint(response.statusCode.toString());
        var data = jsonDecode(response.body);
        debugPrint(data['Status'].toString());
        if (data['Status']) {
          debugPrint(
              {"Dashboard": data['pateintinfo'], "status": datas}.toString());
          return {"Dashboard": data['pateintinfo'], "status": datas};
        } else {
          return data['pateintinfo'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class DoctorDashBoardApi {
  Future FetchStatus() async {
    var url = "$statusurl?doctorid=${Doctor_id.toString()}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['Status']) {
          debugPrint(data['data'][0]['patient_id'].toString());
          return data['data'];
        } else {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future FetchDetials() async {
    try {
      var url = "$doctordetailsUrl?doctor_id=$Doctor_id";

      debugPrint(url.toString());
      final response = await http.get(Uri.parse(url));
      final status = await FetchStatus();
      debugPrint(status.runtimeType.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['Status']) {
          return {
            "Dashboard": data['doctorInfo'],
            "status": status == null ? [] : status
          };
        } else {
          return data['doctorInfo'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class AdminDashBoardApi {
  Future FetchDetials() async {
    try {
      debugPrint(Doctor_id.toString());
      var url = "$admindetailsUrl?doctor_id=$Doctor_id";
      debugPrint(url.toString());
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        var data = jsonDecode(response.body);
        // debugPrint(data['doctorInfo'].toString());
        if (data['Status']) {
          return data['doctorInfo'];
        } else {
          return data['doctorInfo'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
