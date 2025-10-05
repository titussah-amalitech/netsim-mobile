
//A class for the different device types

class DeviceTypes {
  static String routerDevice = 'router';
  static String switchDevice= 'switch';
  static String serverDevice = 'server';
  static String pcDevice = 'pc';
  static String otherDevice = 'other';

//stored in a list form
  static List<String> allDevice= [routerDevice, switchDevice, serverDevice, pcDevice, otherDevice];
} 

class DeviceStatusTypes {
  static String onlineStatus = 'online';
  static String offlineStatus= 'offline';
  static String warningStatus = 'warning';
}