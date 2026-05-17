using Unity.Netcode.Components;
using UnityEngine;

namespace Unity.Netcode.Samples
{
    // Этот скрипт позволяет владельцу (клиенту) самому двигать свой объект
    public class ClientNetworkTransform : NetworkTransform
    {
        protected override bool OnIsServerAuthoritative()
        {
            return false;
        }
    }
}