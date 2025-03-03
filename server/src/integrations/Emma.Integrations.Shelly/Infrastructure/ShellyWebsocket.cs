using Emma.Application.Shared.Logging;
using Emma.Domain;
using Emma.Integrations.Shelly.Domain.ValueObjects;
using Websocket.Client;

namespace Emma.Integrations.Shelly.Infrastructure;

public sealed class ShellyWebsocket : IDisposable
{
    private readonly FullyQualifiedDomainName _host;
    private readonly ShellyWebsocketConfigurationFactory _configurationFactory;
    private readonly ShellyWebsocketMessageHandler _messageHandler;
    private readonly ILogger _logger;

    private IDisposable[] _disposables = [];
    private WebsocketClient? _client;
    private ShellyWebsocketConfiguration? _configuration;

    public ShellyWebsocket(
        FullyQualifiedDomainName host,
        ShellyWebsocketConfigurationFactory configurationFactory,
        ShellyWebsocketMessageHandler messageHandler,
        ILogger logger
    )
    {
        _host = host;
        _configurationFactory = configurationFactory;
        _messageHandler = messageHandler;
        _logger = logger;
    }

    public async Task Start()
    {
        await InitializeClient();
        await _client!.StartOrFail();
    }

    public void Send(string json)
    {
        _client?.Send(json);
    }

    public void Dispose()
    {
        foreach (var disposable in _disposables)
        {
            disposable.Dispose();
        }

        _client?.Dispose();
    }

    private async Task InitializeClient()
    {
        if (_client is not null)
        {
            return;
        }

        _configuration = await _configurationFactory.GetConfiguration(_host);
        _client = new WebsocketClient(_configuration.Uri);
        _disposables =
        [
            _client.DisconnectionHappened.Subscribe(OnDisconnectionHappened),
            _client.ReconnectionHappened.Subscribe(OnReconnectionHappened),
            _client.MessageReceived.Subscribe(OnMessageReceived),
        ];
    }

    private async Task RefreshConfiguration()
    {
        _configuration = await _configurationFactory.GetConfiguration(_host);
        _client!.Url = _configuration.Uri;
        await _client.Reconnect();
    }

    private void OnDisconnectionHappened(DisconnectionInfo info)
    {
        if (_configuration?.ValidUntil <= AmbientTimeProvider.UtcNow)
        {
            info.CancelReconnection = true;
            _ = RefreshConfiguration();
        }
    }

    private void OnReconnectionHappened(ReconnectionInfo info)
    {
        _logger.Info("Reconnection {Type} happened.", info.Type);
    }

    private void OnMessageReceived(ResponseMessage message)
    {
        _ = _messageHandler.Handle(message);
    }
}
