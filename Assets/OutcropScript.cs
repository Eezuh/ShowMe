using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutcropScript : MonoBehaviour
{
    public float FuelInOutcrop;

    private void Update()
    {
        if (FuelInOutcrop <= 0)
        {
            this.gameObject.GetComponent<Renderer>().enabled = false;
        }
    }

    public void Despawn()
    {
        Destroy(this.gameObject);
    }
}
