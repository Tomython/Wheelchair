#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;

public static class WheelchairSetupEditor
{
    const string PrefabPath = "Assets/WheelchairMultiplayer/Prefabs/WheelchairPlayer.prefab";

    [MenuItem("Wheelchair Multiplayer/Create Wheelchair Player Prefab")]
    public static void CreateWheelchairPlayerPrefab()
    {
        var root = new GameObject("WheelchairPlayer");

        var rb = root.AddComponent<Rigidbody>();
        rb.mass = 50f;
        rb.linearDamping = 0.5f;
        rb.angularDamping = 2f;
        rb.interpolation = RigidbodyInterpolation.Interpolate;
        rb.collisionDetectionMode = CollisionDetectionMode.Continuous;

        root.AddComponent<Unity.Netcode.NetworkObject>();
        var nt = root.AddComponent<Unity.Netcode.Components.NetworkTransform>();
        nt.AuthorityMode = Unity.Netcode.Components.NetworkTransform.AuthorityModes.Owner;
        root.AddComponent<WheelchairController>();
        root.AddComponent<RagdollSeatJoint>();

        var seat = new GameObject("Seat");
        seat.transform.SetParent(root.transform);
        seat.transform.localPosition = new Vector3(0, 0.5f, 0);
        seat.transform.localRotation = Quaternion.identity;
        seat.transform.localScale = Vector3.one;

        var mesh = new GameObject("Mesh");
        mesh.transform.SetParent(root.transform);
        mesh.transform.localPosition = Vector3.zero;
        mesh.transform.localRotation = Quaternion.identity;
        mesh.transform.localScale = Vector3.one;

        var ragdollRoot = new GameObject("Ragdoll");
        ragdollRoot.transform.SetParent(root.transform);
        ragdollRoot.transform.localPosition = new Vector3(0, 0.6f, 0);
        ragdollRoot.transform.localRotation = Quaternion.identity;
        ragdollRoot.transform.localScale = Vector3.one;

        var dir = System.IO.Path.GetDirectoryName(PrefabPath);
        if (!System.IO.Directory.Exists(dir))
            System.IO.Directory.CreateDirectory(dir);

        var prefab = PrefabUtility.SaveAsPrefabAsset(root, PrefabPath);
        Object.DestroyImmediate(root);

        var joint = prefab.GetComponent<RagdollSeatJoint>();
        var so = new SerializedObject(joint);
        so.FindProperty("pelvisTransform").objectReferenceValue = null;
        so.FindProperty("seatAnchor").objectReferenceValue = prefab.transform.Find("Seat");
        so.FindProperty("wheelchairRigidbody").objectReferenceValue = prefab.GetComponent<Rigidbody>();
        so.ApplyModifiedPropertiesWithoutUndo();

        Selection.activeObject = prefab;
        Debug.Log($"[Wheelchair] Prefab created at {PrefabPath}. Assign Pelvis (from your ragdoll) and wheelchair mesh in inspector.");
    }

    [MenuItem("Wheelchair Multiplayer/Add Prefab to NetworkPrefabs")]
    public static void AddPrefabToNetworkPrefabs()
    {
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(PrefabPath);
        if (prefab == null) { Debug.LogError($"[Wheelchair] Prefab not found at {PrefabPath}. Run Create Wheelchair Player Prefab first."); return; }

        var listAsset = AssetDatabase.LoadAssetAtPath<Unity.Netcode.NetworkPrefabsList>("Assets/DefaultNetworkPrefabs.asset");
        if (listAsset == null) { Debug.LogError("[Wheelchair] DefaultNetworkPrefabs.asset not found."); return; }

        if (listAsset.Contains(prefab)) { Debug.Log("[Wheelchair] Prefab already in NetworkPrefabs."); return; }

        listAsset.Add(new Unity.Netcode.NetworkPrefab { Prefab = prefab });
        EditorUtility.SetDirty(listAsset);
        AssetDatabase.SaveAssets();
        Debug.Log("[Wheelchair] Prefab added to DefaultNetworkPrefabs.");
    }

    [MenuItem("Wheelchair Multiplayer/Setup Lobby Scene")]
    public static void SetupLobbyScene()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);

        var nmGo = new GameObject("NetworkManager");
        nmGo.AddComponent<Unity.Netcode.NetworkManager>();
        var transport = nmGo.AddComponent<Unity.Netcode.Transports.UTP.UnityTransport>();
        var nm = nmGo.GetComponent<Unity.Netcode.NetworkManager>();
        nm.NetworkConfig.NetworkTransport = transport;
        nm.NetworkConfig.EnableSceneManagement = true;

        var lobbyGo = new GameObject("LobbyManager");
        lobbyGo.AddComponent<WheelchairLobbyManager>();
        lobbyGo.AddComponent<WheelchairLobbyUI>();

        var canvasGo = new GameObject("Canvas");
        var canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvasGo.AddComponent<UnityEngine.UI.CanvasScaler>();
        canvasGo.AddComponent<UnityEngine.UI.GraphicRaycaster>();

        var panel = new GameObject("Panel");
        panel.transform.SetParent(canvasGo.transform, false);
        var rect = panel.AddComponent<RectTransform>();
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = rect.offsetMax = Vector2.zero;

        var createHostBtn = CreateButton(panel.transform, "Create Host", new Vector2(0, 100), "CreateHost");
        var joinBtn = CreateButton(panel.transform, "Join", new Vector2(0, 40), "Join");
        var ipInput = CreateInputField(panel.transform, "127.0.0.1", new Vector2(0, -20));
        var startBtn = CreateButton(panel.transform, "Start Game", new Vector2(0, -80), "StartGame");

        var spawnRoot = new GameObject("SpawnPoints");
        for (int i = 0; i < 4; i++)
        {
            var sp = new GameObject($"SpawnPoint_{i}");
            sp.transform.SetParent(spawnRoot.transform);
            sp.transform.position = new Vector3(i * 3f, 0, 0);
        }

        var lobby = lobbyGo.GetComponent<WheelchairLobbyManager>();
        var lobbyUI = lobbyGo.GetComponent<WheelchairLobbyUI>();
        var so = new SerializedObject(lobby);
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(PrefabPath);
        if (prefab) so.FindProperty("wheelchairPrefab").objectReferenceValue = prefab;
        var spawns = new Transform[4];
        for (int i = 0; i < 4; i++)
            spawns[i] = spawnRoot.transform.GetChild(i);
        so.FindProperty("spawnPoints").ClearArray();
        for (int i = 0; i < 4; i++)
        {
            so.FindProperty("spawnPoints").InsertArrayElementAtIndex(i);
            so.FindProperty("spawnPoints").GetArrayElementAtIndex(i).objectReferenceValue = spawns[i];
        }
        so.ApplyModifiedPropertiesWithoutUndo();

        var uiSo = new SerializedObject(lobbyUI);
        uiSo.FindProperty("createHostButton").objectReferenceValue = createHostBtn;
        uiSo.FindProperty("joinButton").objectReferenceValue = joinBtn;
        uiSo.FindProperty("startGameButton").objectReferenceValue = startBtn;
        uiSo.FindProperty("ipInputField").objectReferenceValue = ipInput;
        uiSo.ApplyModifiedPropertiesWithoutUndo();

        EditorSceneManager.SaveScene(scene, "Assets/Scenes/Lobby.unity");
        Debug.Log("[Wheelchair] Lobby scene created at Assets/Scenes/Lobby.unity");
    }

    static Button CreateButton(Transform parent, string label, Vector2 anchoredY, string goName = null)
    {
        var go = new GameObject(goName ?? label.Replace(" ", ""));
        go.transform.SetParent(parent, false);
        var rect = go.AddComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.5f, 0.5f);
        rect.anchorMax = new Vector2(0.5f, 0.5f);
        rect.sizeDelta = new Vector2(160, 30);
        rect.anchoredPosition = anchoredY;
        go.AddComponent<Image>().color = new Color(0.2f, 0.5f, 0.8f);
        var btn = go.AddComponent<Button>();
        var textGo = new GameObject("Text");
        textGo.transform.SetParent(go.transform, false);
        var text = textGo.AddComponent<TextMeshProUGUI>();
        text.text = label;
        text.alignment = TextAlignmentOptions.Center;
        text.fontSize = 14;
        var textRect = text.rectTransform;
        textRect.anchorMin = Vector2.zero;
        textRect.anchorMax = Vector2.one;
        textRect.offsetMin = textRect.offsetMax = Vector2.zero;
        return btn;
    }

    static TMP_InputField CreateInputField(Transform parent, string defaultText, Vector2 pos)
    {
        var go = new GameObject("IPInput");
        go.transform.SetParent(parent, false);
        var rect = go.AddComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.5f, 0.5f);
        rect.anchorMax = new Vector2(0.5f, 0.5f);
        rect.sizeDelta = new Vector2(200, 30);
        rect.anchoredPosition = pos;
        go.AddComponent<Image>().color = new Color(1, 1, 1, 0.2f);
        var input = go.AddComponent<TMP_InputField>();
        var textArea = new GameObject("TextArea");
        textArea.transform.SetParent(go.transform, false);
        var textAreaRect = textArea.AddComponent<RectTransform>();
        textAreaRect.anchorMin = Vector2.zero;
        textAreaRect.anchorMax = Vector2.one;
        textAreaRect.offsetMin = new Vector2(5, 2);
        textAreaRect.offsetMax = new Vector2(-5, -2);
        var text = textArea.AddComponent<TextMeshProUGUI>();
        text.text = defaultText;
        text.fontSize = 14;
        input.textViewport = textAreaRect;
        input.textComponent = text;
        return input;
    }
}
#endif
