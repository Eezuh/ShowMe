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

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (rotateRestricted)
        {
            DoFixedRotation(Time.fixedDeltaTime);
        }
        else
        {
            transform.Rotate(new Vector3(0, 1, 0) * rotateSpeed * Time.fixedDeltaTime);
        }
    }

    private void DoFixedRotation(float time)
    {
        if(transform.rotation.eulerAngles.y > rotateEnd && transform.rotation.y > rotateStart)
        {
            rotateBack = true;
        }
        else if(transform.rotation.y < rotateStart)
        {
            rotateBack = false;
        }

        transform.Rotate(new Vector3(0, 1, 0) * ((rotateBack) ? -rotateSpeed : rotateSpeed) * time);
    }
}
