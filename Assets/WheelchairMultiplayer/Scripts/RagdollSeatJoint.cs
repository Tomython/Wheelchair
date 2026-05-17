using Unity.Netcode;
using UnityEngine;

/// <summary>
/// Creates and configures ConfigurableJoint between ragdoll Pelvis and wheelchair Seat.
/// Runs on server at spawn. Pelvis is connected to wheelchair Rigidbody via seat anchor.
/// </summary>
[RequireComponent(typeof(Rigidbody))]
public class RagdollSeatJoint : NetworkBehaviour
{
    [Header("References")]
    [SerializeField] Transform pelvisTransform;
    [SerializeField] Transform seatAnchor;
    [SerializeField] Rigidbody wheelchairRigidbody;

    public override void OnNetworkSpawn()
    {
        if (!IsServer) return;
        SetupJoint();
    }

    void SetupJoint()
    {
        if (pelvisTransform == null || seatAnchor == null || wheelchairRigidbody == null)
        {
            Debug.LogWarning($"[RagdollSeatJoint] Missing references on {gameObject.name}. Assign Pelvis, SeatAnchor, WheelchairRigidbody.");
            return;
        }

        var pelvisRb = pelvisTransform.GetComponent<Rigidbody>();
        if (pelvisRb == null)
        {
            Debug.LogWarning($"[RagdollSeatJoint] Pelvis has no Rigidbody: {pelvisTransform.name}");
            return;
        }

        var joint = pelvisTransform.gameObject.AddComponent<ConfigurableJoint>();
        joint.connectedBody = wheelchairRigidbody;

        // Anchor in pelvis local space (center)
        joint.anchor = pelvisTransform.InverseTransformPoint(seatAnchor.position);
        joint.connectedAnchor = seatAnchor.localPosition;

        // Linear: Y locked, XZ limited 0.2m
        joint.yMotion = ConfigurableJointMotion.Locked;
        joint.xMotion = ConfigurableJointMotion.Limited;
        joint.zMotion = ConfigurableJointMotion.Limited;
        var linearLimit = new SoftJointLimit { limit = 0.2f, bounciness = 0, contactDistance = 0 };
        joint.linearLimit = linearLimit;
        joint.linearLimitSpring = new SoftJointLimitSpring { spring = 800f, damper = 30f };

        // Angular: limited ~20°
        joint.angularXMotion = ConfigurableJointMotion.Limited;
        joint.angularYMotion = ConfigurableJointMotion.Limited;
        joint.angularZMotion = ConfigurableJointMotion.Limited;
        float angleLimit = 20f * Mathf.Deg2Rad;
        joint.lowAngularXLimit = new SoftJointLimit { limit = -angleLimit, bounciness = 0, contactDistance = 0 };
        joint.highAngularXLimit = new SoftJointLimit { limit = angleLimit, bounciness = 0, contactDistance = 0 };
        joint.angularYLimit = new SoftJointLimit { limit = angleLimit, bounciness = 0, contactDistance = 0 };
        joint.angularZLimit = new SoftJointLimit { limit = angleLimit, bounciness = 0, contactDistance = 0 };
        joint.angularXLimitSpring = new SoftJointLimitSpring { spring = 150f, damper = 20f };
        joint.angularYZLimitSpring = new SoftJointLimitSpring { spring = 150f, damper = 20f };

        // Position drives for XZ (spring 800, damper 30)
        joint.xDrive = new JointDrive { positionSpring = 800f, positionDamper = 30f, maximumForce = Mathf.Infinity };
        joint.yDrive = new JointDrive { positionSpring = 800f, positionDamper = 30f, maximumForce = Mathf.Infinity };
        joint.zDrive = new JointDrive { positionSpring = 800f, positionDamper = 30f, maximumForce = Mathf.Infinity };
    }
}
