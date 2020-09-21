application: fuelco {
  label: "FuelCo PPO Application"
  # url: "http://localhost:8080/bundle.js"
  file: "js/bundle.js"
  entitlements: {
    allow_same_origin: yes
    navigation: yes
    core_api_methods: [
       "user_attribute_user_values"
    ]
  }
}

localization_settings: {
  default_locale: en
  localization_level: permissive
}
