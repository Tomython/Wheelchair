using UnityEngine;
using Unity.Netcode;

namespace AzureNature
{
    public class MouseLook : NetworkBehaviour
    {
        [Header("Настройки чувствительности")]
        public float mouseSensitivity = 2f;

        private float xRotation = 0f; // Наклон вверх-вниз
        private float yRotation = 0f; // Поворот влево-вправо

        private Camera cam;
        private AudioListener audioListener;

        private void Awake()
        {
            cam = GetComponent<Camera>();
            audioListener = GetComponent<AudioListener>();
        }

        public override void OnNetworkSpawn()
        {
            if (IsOwner)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
            else
            {
                // Отключаем чужие камеры и уши
                if (cam != null) cam.enabled = false;
                if (audioListener != null) audioListener.enabled = false;
            }
        }

        private void Update()
        {
            // Работаем только если это наш персонаж
            if (!IsOwner) return;

            CameraRotation();
        }

        private void CameraRotation()
        {
            float mouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
            float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;

            // Считаем вращение влево-вправо (по оси Y)
            yRotation += mouseX;

            // Считаем вращение вверх-вниз (по оси X) и ограничиваем его
            xRotation -= mouseY;
            xRotation = Mathf.Clamp(xRotation, -90f, 90f);

            // Применяем вращение к камере
            // Внимание: мы используем localRotation, чтобы не зависеть от родителей
            transform.localRotation = Quaternion.Euler(xRotation, yRotation, 0f);
        }
    }
}