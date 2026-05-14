from django.apps import AppConfig

class AwesomevmsConfig(AppConfig):
    name = 'awesomevms.awesomevms'

    def ready(self):
        from bomiot.server.core.signal import bomiot_signals, bomiot_data_signals
