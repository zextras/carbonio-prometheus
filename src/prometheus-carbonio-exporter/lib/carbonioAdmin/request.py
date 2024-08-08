from pythonzimbra.tools import auth
from pythonzimbra.communication import Communication
import ssl

class ZimbraMailRequest(object):

    def __init__(self, url, account, key):
        self._base_url = url
        self._account = account
        self._key = key
        self._url_prefix = "/service/admin/soap"
        self._namespace = 'urn:zimbraAdmin'
        self._build_url()
        self._context = ssl.create_default_context()
        self._context.check_hostname = False
        self._context.verify_mode = ssl.CERT_NONE
        self._init_connection()
        self._generate_user_token()


    def _build_url(self):
        self.full_url = self._base_url + self._url_prefix

    def _init_connection(self):
        self.connection = Communication(self.full_url, context=self._context)

    def _generate_user_token(self):
        self._usr_token = auth.authenticate(self.full_url, self._account, self._key,admin_auth=True, use_password=True, context=self._context)

    def GetActiveSession(self):
        request_name = 'DumpSessionsRequest'
        request = self.connection.gen_request(token=self._usr_token)
        request.add_request(
            request_name,
            {"listSessions": 1, "groupByAccount": 1},
            self._namespace
        )
        response = self.connection.send_request(request)
        data = response.get_response()
        response.clean()
        return data