using Unity.Netcode;
using UnityEngine;

#if UNITY_SERVICES_RELAY_INSTALLED
using System.Threading.Tasks;
#endif

/// <summary>
/// Lobby UI and spawn logic. Spawns wheelchair for each client on connect.
/// Supports: Create Host, Join (IP:Port), optional Relay (if Unity Services installed).
/// </summary>
public class WheelchairLobbyManager : MonoBehaviour
{
    [Header("Prefab & Spawn")]
    [SerializeField] GameObject wheelchairPrefab;
    [SerializeField] Transform[] spawnPoints;

    [Header("Connection")]
    [SerializeField] string defaultAddress = "127.0.0.1";
    [SerializeField] ushort port = 7777;

    NetworkManager _nm;

    void Awake()
    {
        _nm = NetworkManager.Singleton;
        if (_nm == null)
        {
            Debug.LogError("[WheelchairLobby] NetworkManager not found. Add NetworkManager to the scene.");
            return;
        }
    }

    void OnEnable()
    {
        if (_nm != null)
            _nm.OnClientConnectedCallback += OnClientConnected;
    }

    void OnDisable()
    {
        if (_nm != null)
            _nm.OnClientConnectedCallback -= OnClientConnected;
    }

    void OnClientConnected(ulong clientId)
    {
        if (!_nm.IsServer) return;
        SpawnPlayerForClient(clientId);
    }

    public void SpawnPlayerForClient(ulong clientId)
    {
        if (!_nm.IsServer || wheelchairPrefab == null) return;

        var no = wheelchairPrefab.GetComponent<NetworkObject>();
        if (no == null)
        {
            Debug.LogError("[WheelchairLobby] Wheelchair prefab has no NetworkObject.");
            return;
        }

        Transform spawn = (spawnPoints != null && spawnPoints.Length > 0)
            ? spawnPoints[Random.Range(0, spawnPoints.Length)]
            : null;
        Vector3 pos = spawn != null ? spawn.position : Vector3.zero;
        Quaternion rot = spawn != null ? spawn.rotation : Quaternion.identity;

        var instance = Instantiate(wheelchairPrefab, pos, rot);
        instance.GetComponent<NetworkObject>().SpawnAsPlayerObject(clientId);
    }

    public void CreateHost()
    {
        if (_nm == null) return;
        _nm.StartHost();
    }

    public void JoinWithIP(string address = null)
    {
        if (_nm == null) return;

        string ip = string.IsNullOrEmpty(address) ? defaultAddress : address;

        var transport = _nm.GetComponent<Unity.Netcode.Transports.UTP.UnityTransport>();
        if (transport != null)
            transport.SetConnectionData(ip, port);

        _nm.StartClient();
    }

    public void StartGame(string sceneName = "GameScene")
    {
        if (!_nm.IsServer) return;
        _nm.SceneManager.LoadScene(sceneName, UnityEngine.SceneManagement.LoadSceneMode.Single);
    }
}
