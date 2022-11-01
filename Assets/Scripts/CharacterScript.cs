using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterScript : MonoBehaviour
{
    private float health;
    private float WaterFuel;
    private float RaftFuelHolding;

    public float ShortBlastDamage;
    public float StreamDamagePerSecond;

    private float HoldStartTime;
    public float StreamDelay;
    private bool AttackIsStream;

    public GameObject Attack_Blast;
    public GameObject Attack_Stream;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            HoldStartTime = Time.time;
        }

        if (Input.GetKey(KeyCode.Mouse0))
        {
            if (Time.time >= HoldStartTime + StreamDelay)
            {
                AttackIsStream = true;
            }
        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            if (AttackIsStream == false)
            {
                FireShortBlast();
            }
            AttackIsStream = false;
        }

        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            AttackIsStream = false;
            //switch weapons
        }

        if (Input.GetKey(KeyCode.Mouse1))
        {
            //zuckk
        }
    }

    private void FireShortBlast()
    {
        //fire wit power based on available fuel;
        //lower fuel amount

    }

    private void FireStream()
    {
        //shoot stream every time function is called (once a second or so) and calculate distance based on fuel amount every time -> IENumerator probs
        //lower fuel amount every time
    }
}

