using System.Web;
using Emma.Application.Shared;
using Emma.Application.Shared.Identity;

namespace Emma.Integrations.Shelly.PermissionsGrant;

/// <summary>
/// See https://shelly-api-docs.shelly.cloud/integrator-api/users.
/// </summary>
public class ShellyPermissionGrantUriQuery
    : IQuery<ShellyPermissionGrantUriQuery.ShellyPermissionGrantUriResponse>
{
    public class Handler
        : IQueryHandler<ShellyPermissionGrantUriQuery, ShellyPermissionGrantUriResponse>
    {
        private readonly ShellyIntegrationConfiguration _configuration;
        private readonly ICurrentUserReader _currentUserReader;

        public Handler(
            ShellyIntegrationConfiguration configuration,
            ICurrentUserReader currentUserReader
        )
        {
            _configuration = configuration;
            _currentUserReader = currentUserReader;
        }

        public Task<ShellyPermissionGrantUriResponse> Handle(
            ShellyPermissionGrantUriQuery request,
            CancellationToken cancellationToken
        )
        {
            var baseUri = _configuration.CallbackBaseUri;
            var userId = _currentUserReader.GetUserIdOrThrow();
            var callbackUri = new Uri(
                $"{baseUri?.ToString().TrimEnd('/')}/integrations/shelly/v1/callback?user={userId}"
            );

            var tag = _configuration.IntegratorTag;
            var url = new Uri(
                $"https://my.shelly.cloud/integrator.html?itg={tag}&cb={HttpUtility.UrlEncode(callbackUri.ToString())}"
            );

            var response = new ShellyPermissionGrantUriResponse(url);
            return Task.FromResult(response);
        }
    }

    public record ShellyPermissionGrantUriResponse(Uri Uri);
}
