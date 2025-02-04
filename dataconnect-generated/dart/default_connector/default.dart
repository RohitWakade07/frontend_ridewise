library default_connector;

import 'package:firebase_data_connect/firebase_data_connect.dart';

class DefaultConnector {
  static final ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',  // Region
    'default',       // Environment
    'frontend',      // Project/Name
  );

  final FirebaseDataConnect dataConnect;

  DefaultConnector({required this.dataConnect});

  // Singleton instance
  static DefaultConnector get instance {
    // Create an instance of DefaultConnector with the FirebaseDataConnect instance
    return DefaultConnector(
      dataConnect: FirebaseDataConnect.instanceFor(connectorConfig: connectorConfig),
    );
  }
}
