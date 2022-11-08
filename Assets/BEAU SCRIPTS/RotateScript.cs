using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateScript : MonoBehaviour
{
    public bool rotateRestricted;
    public float rotateStart;
    public float rotateEnd;
    private bool rotateBack;
    public float rotateSpeed;

    private Vector3 from = new Vector3(0, 0, 0);
    private Vector3 to = new Vector3(0, 0, 0);

    // Start is called before the first frame update
    void Start()
    {
        from.y = rotateStart;
        to.y = rotateEnd;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (rotateRestricted)
        {
            Quaternion from = Quaternion.Euler(this.from);
            Quaternion to = Quaternion.Euler(this.to);

            float lerp = 0.5F * (1.0F + Mathf.Sin(Mathf.PI * Time.realtimeSinceStartup * rotateSpeed / 10));
            transform.localRotation = Quaternion.Lerp(from, to, lerp);
        }
        else
        {
            transform.Rotate(new Vector3(0, 1, 0) * rotateSpeed * Time.fixedDeltaTime);
        }
    }
}
