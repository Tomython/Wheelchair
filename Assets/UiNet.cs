using UnityEngine;
using UnityEngine.UI;
using Unity.Netcode;
using Unity.Services.Core;
using Unity.Services.Relay;
using Unity.Services.Relay.Models;
using Unity.Netcode.Transports.UTP;
using Unity.Services.Authentication; // Добавлено: для авторизации
using TMPro;

public class UiNet : MonoBehaviour
{
    [SerializeField] private Button HostButton;
    [SerializeField] private Button ClientButton;
    [SerializeField] private TMP_InputField JoinCodeInput; 

    private void Start()
    {
        HostButton.onClick.AddListener(HostButtonOnClick);
        ClientButton.onClick.AddListener(ClientButtonOnClick);
    }

    private async void HostButtonOnClick() 
    {
        try 
        {
            await UnityServices.InitializeAsync();

            // Входим в систему анонимно (исправляет твою ошибку)
            if (!AuthenticationService.Instance.IsSignedIn)
            {
                await AuthenticationService.Instance.SignInAnonymouslyAsync();
            }

            Allocation allocation = await RelayService.Instance.CreateAllocationAsync(3);
            string joinCode = await RelayService.Instance.GetJoinCodeAsync(allocation.AllocationId);
        
            Debug.Log($"ИГРА СОЗДАНА. КОД ДЛЯ ДРУГА: {joinCode}");
            if (JoinCodeInput != null) JoinCodeInput.text = joinCode;

            var transport = NetworkManager.Singleton.GetComponent<UnityTransport>();
            transport.SetRelayServerData(
                allocation.RelayServer.IpV4,
                (ushort)allocation.RelayServer.Port,
                allocation.AllocationIdBytes,
                allocation.Key,
                allocation.ConnectionData
            );

            NetworkManager.Singleton.StartHost();
        }
        catch (System.Exception e) 
        {
            Debug.LogError($"Ошибка создания хоста: {e.Message}");
        }
    }

    private async void ClientButtonOnClick()
    {
        if (string.IsNullOrEmpty(JoinCodeInput.text))
        {
            Debug.LogError("Сначала введи код в текстовое поле!");
            return;
        }

        try
        {
            await UnityServices.InitializeAsync();

            // Клиент тоже должен войти в систему
            if (!AuthenticationService.Instance.IsSignedIn)
            {
                await AuthenticationService.Instance.SignInAnonymouslyAsync();
            }

            JoinAllocation joinAllocation = await RelayService.Instance.JoinAllocationAsync(JoinCodeInput.text);

            var transport = NetworkManager.Singleton.GetComponent<UnityTransport>();
            transport.SetRelayServerData(
                joinAllocation.RelayServer.IpV4,
                (ushort)joinAllocation.RelayServer.Port,
                joinAllocation.AllocationIdBytes,
                joinAllocation.Key,
                joinAllocation.ConnectionData,
                joinAllocation.HostConnectionData
            );

            NetworkManager.Singleton.StartClient();
            Debug.Log("Подключаемся...");
        }
        catch (System.Exception e)
        {
            Debug.LogError($"Ошибка подключения: {e.Message}");
        }
    }
}