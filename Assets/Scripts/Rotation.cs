using UnityEngine;

public class Rotation : MonoBehaviour
{
    public float rotationSpeed = 50f;

    void Update() {   
        float angle = rotationSpeed * Time.deltaTime;      
        transform.Rotate(Vector3.up, angle);
    }
}
