using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutcropScript : MonoBehaviour
{
    public float FuelInOutcrop;
    public GameObject Mesh;
    private float startingFuel;

    private void Start()
    {
        startingFuel = FuelInOutcrop;
    }

    private void Update()
    {
        float newScale = (FuelInOutcrop / startingFuel > 0f) ? FuelInOutcrop / startingFuel : 0.01f;
        if (FuelInOutcrop <= 0 && Mesh.GetComponent<Renderer>().enabled)
        {
            GetComponent<AudioSource>().Play();
            Mesh.GetComponent<Renderer>().enabled = false;
        }

        Mesh.transform.localScale = new Vector3(newScale, newScale, newScale);
    }

    public void Despawn()
    {
        Destroy(this.gameObject);
    }
}
