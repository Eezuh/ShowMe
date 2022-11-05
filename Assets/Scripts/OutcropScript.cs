using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutcropScript : MonoBehaviour
{
    public float FuelInOutcrop;
    public GameObject Mesh;

    private void Update()
    {
        if (FuelInOutcrop <= 0)
        {
            Mesh.GetComponent<Renderer>().enabled = false;
        }
    }

    public void Despawn()
    {
        Destroy(this.gameObject);
    }
}
