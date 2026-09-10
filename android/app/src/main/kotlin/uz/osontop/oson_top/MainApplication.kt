package uz.osontop.oson_top

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Kalit local.properties dan keladi (BuildConfig orqali)
        if (BuildConfig.MAPKIT_API_KEY.isNotEmpty()) {
            MapKitFactory.setApiKey(BuildConfig.MAPKIT_API_KEY)
            MapKitFactory.setLocale("uz_UZ")
        }
    }
}
