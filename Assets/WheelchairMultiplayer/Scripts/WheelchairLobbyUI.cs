using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Binds UI elements to WheelchairLobbyManager. Add to Canvas or a parent of the lobby UI.
/// </summary>
[RequireComponent(typeof(WheelchairLobbyManager))]
public class WheelchairLobbyUI : MonoBehaviour
{
    [Header("Buttons")]
    [SerializeField] Button createHostButton;
    [SerializeField] Button joinButton;
    [SerializeField] Button startGameButton;

    [Header("Inputs")]
    [SerializeField] TMP_InputField ipInputField;

    WheelchairLobbyManager _lobby;

    void Awake()
    {
        _lobby = GetComponent<WheelchairLobbyManager>();
    }

    void OnEnable()
    {
        if (createHostButton) createHostButton.onClick.AddListener(OnCreateHost);
        if (joinButton) joinButton.onClick.AddListener(OnJoin);
        if (startGameButton) startGameButton.onClick.AddListener(OnStartGame);
    }

    void OnDisable()
    {
        if (createHostButton) createHostButton.onClick.RemoveListener(OnCreateHost);
        if (joinButton) joinButton.onClick.RemoveListener(OnJoin);
        if (startGameButton) startGameButton.onClick.RemoveListener(OnStartGame);
    }

    void OnCreateHost() => _lobby?.CreateHost();
    void OnStartGame() => _lobby?.StartGame();

    void OnJoin()
    {
        if (_lobby == null) return;
        string ip = ipInputField != null && !string.IsNullOrWhiteSpace(ipInputField.text)
            ? ipInputField.text.Trim()
            : null;
        _lobby.JoinWithIP(ip);
    }
}
