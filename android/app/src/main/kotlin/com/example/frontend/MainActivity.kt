// Add this import
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.googlemaps.GoogleMapsPlugin

class MainActivity : FlutterActivity() {
    @Override
    protected fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMapsPlugin.registerWith(flutterEngine.getDartExecutor()) // Register plugin
    }
}