

enum Environment { DEV, PROD }

class Constants {
  static late Map<String, dynamic> _config;

  static void setEnvironment(Environment env) {
    switch (env) {
      case Environment.DEV:
        _config = _Config.devConstants;
        break;
      case Environment.PROD:
        _config = _Config.prodConstants;
        break;
    }
  }

  static String? get API_URI {
    return _config[_Config.API_URI];
  }

  static String? get WHERE_AM_I {
    return _config[_Config.WHERE_AM_I];
  }

  static String? get HOME_CAMPAIGN_ID {
    return _config[_Config.HOME_CAMPAIGN_ID];
  }

  static String? get HOME_MEDIA_BUNDLE {
    return _config[_Config.HOME_MEDIA_BUNDLE];
  }

  static String? get FRANCHISE_ID {
    return _config[_Config.FRANCHISE_ID];
  }

  static String? get FRANCHISE_STORE_TAGS_MEDIA_BUNDLE {
    return _config[_Config.FRANCHISE_STORE_TAGS_MEDIA_BUNDLE];
  }

  static String? get STRIPE_KEY {
    return _config[_Config.STRIPE_KEY];
  }

  static String? get STRIPE_MODE {
    return _config[_Config.STRIPE_MODE];
  }

  static String? get DELIVERY_POSTCODE {
    return _config[_Config.DELIVERY_POSTCODE];
  }

  static String? get DELIVERY_CITY {
    return _config[_Config.DELIVERY_CITY];
  }
}

class _Config {
  static const API_URI = "APIRUI";
  static const WHERE_AM_I = "WHERE_AM_I";
  static const HOME_CAMPAIGN_ID = "HOME_CAMPAIGN_ID";
  static const HOME_MEDIA_BUNDLE = "HOME_MEDIA_BUNDLE";
  static const FRANCHISE_ID = "FRANCHISE_ID";
  static const FRANCHISE_STORE_TAGS_MEDIA_BUNDLE =
      "FRANCHISE_STORE_TAGS_MEDIA_BUNDLE";
  static const STRIPE_KEY = "STRIPE_KEY";
  static const STRIPE_MODE = "STRIPE_MODE";
  static const DELIVERY_POSTCODE = "DELIVERY_POSTCODE";
  static const DELIVERY_CITY = "DELIVERY_CITY";

  static Map<String, String> devConstants = {
    API_URI: 'https://api.linkpos.com.au',
    WHERE_AM_I: "local",
    HOME_CAMPAIGN_ID: 'f8b5e648-c3f7-4eed-b206-48b1b9a10765',
    HOME_MEDIA_BUNDLE: 'test',
    FRANCHISE_ID: 'f6c33159-de3a-4756-924d-133d2ca0aa0d',
    FRANCHISE_STORE_TAGS_MEDIA_BUNDLE: 'bwc_tags',
    STRIPE_KEY: 'pk_test_crlEIF9fbrjYye10Aol7tkEI00suP9zDkz',
    STRIPE_MODE: 'test',
    DELIVERY_POSTCODE: '2134',
    DELIVERY_CITY: 'Burwood'
  };

  static Map<String, String> prodConstants = {
    API_URI: 'https://api.linkaumall.com',
    WHERE_AM_I: "prod",
    HOME_CAMPAIGN_ID: '86bfc316-970c-4368-a657-3cbe2fd45383',
    HOME_MEDIA_BUNDLE: 'Burwood-Chinatown',
    FRANCHISE_ID: '49134922-8352-4e16-9335-7a01e5a5be5c',
    FRANCHISE_STORE_TAGS_MEDIA_BUNDLE: 'bwc_tags',
    STRIPE_KEY: 'pk_live_VTVHCl7qtgvtEw5Wa8TDMLjJ00ubd9akfO',
    STRIPE_MODE: 'production',
    DELIVERY_POSTCODE: '2134',
    DELIVERY_CITY: 'Burwood'
  };
}
