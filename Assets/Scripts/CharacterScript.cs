using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterScript : MonoBehaviour
{
    private float health;
    public float MaxWaterFuelAmount;
    private float CurrentWaterFuelAmount;
    private float WaterFuelPercentage;
    private float RaftFuelHolding;

    public GameObject PlayerGun;
    public GameObject FirePoint;
    public GameObject MineralVacuum;

    public GameObject OnHandPos;
    public GameObject OffHandPos;

    public float ShortBlastDamage;
    public float StreamDamagePerSecond;

    public float ShortBlastCost;
    public float StreamAttackCostPerSecond;

    public float MaxBlastAttackVelocity;

    private float HoldStartTime;
    public float StreamDelay;
    private bool AttackIsStream;

    public GameObject Attack_Blast;
    public GameObject Attack_Stream;
    public GameObject WaterDownPoint;
    public GameObject WaterDownObject;
    public float AttackStreamLength;

    private bool InOutcropRange;
    private GameObject CurrentOutcrop;
    public float SuckSpeed;

    private void Start()
    {
        InitializeItemPosition();
        CurrentWaterFuelAmount = MaxWaterFuelAmount;
        Attack_Stream.SetActive(false);
        WaterDownObject.SetActive(false);
        InOutcropRange = false;
        RaftFuelHolding = 0;
    }

    private void Update()
    {
        CalculateWaterFuelPercentage();
        Debug.Log(WaterFuelPercentage);

        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            HoldStartTime = Time.time;
        }

        if (Input.GetKey(KeyCode.Mouse0))
        {
            if (Time.time >= HoldStartTime + StreamDelay)
            {
                FireStream();
                Debug.Log("Stream Attack");
            }
        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            if (AttackIsStream == false)
            {
                FireShortBlast();
                Debug.Log("shortblast");
            }
            Attack_Stream.SetActive(false);
            WaterDownObject.SetActive(false);
            AttackIsStream = false;
        }

        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            AttackIsStream = false;
            SwitchItems();
            //switch weapons
        }

        if (Input.GetKey(KeyCode.Mouse1))
        {
            SuckMineralFuel();
        }

        if (Input.GetKeyUp(KeyCode.Mouse1))
        {
            SwitchItems();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 6)
        {
            Debug.Log("triggerenter");
            InOutcropRange = true;
            CurrentOutcrop = other.gameObject;
        }
    }

    private void OnTriggerExit(Collider other) //see if this works with edstroying the object
    {
        if (other.gameObject.layer == 6)
        {
            if (CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop <= 0)
            {
                CurrentOutcrop.GetComponent<OutcropScript>().Despawn();
            }
            Debug.Log("triggerexit");
            InOutcropRange = false;
            CurrentOutcrop = null;
        }
    }

    private void FireShortBlast() //Dpesnt work yet :(((
    {
        //fire wit power based on available fuel;
        //lower fuel amount

        GameObject Projectile = Instantiate(Attack_Blast, FirePoint.transform.position, FirePoint.transform.rotation);
        Projectile.GetComponent<Rigidbody>().AddRelativeForce(new Vector3(0, 0, MaxBlastAttackVelocity*WaterFuelPercentage));
        Debug.Log("Instantiate");
        CurrentWaterFuelAmount -= ShortBlastCost;

    }

    private void FireStream()
    {
        if (AttackIsStream == false)
        {
            Attack_Stream.SetActive(true);
            WaterDownObject.SetActive(true);
            AttackIsStream = true;
        }

        Attack_Stream.transform.localScale =  new Vector3(0.2f, 0.2f, AttackStreamLength * WaterFuelPercentage);
        WaterDownPoint.transform.localPosition = new Vector3(WaterDownPoint.transform.localPosition.x, WaterDownPoint.transform.localPosition.y, 245 * WaterFuelPercentage);
        CurrentWaterFuelAmount -= StreamAttackCostPerSecond;

    }

    private void InitializeItemPosition()
    {
        PlayerGun.transform.position = OnHandPos.transform.position;
        PlayerGun.transform.rotation = OnHandPos.transform.rotation;
        MineralVacuum.transform.position = OffHandPos.transform.position;
        MineralVacuum.transform.rotation = OffHandPos.transform.rotation;
    }

    private void SwitchItems()
    {
        if(PlayerGun.transform.position == OnHandPos.transform.position)
        {
            PlayerGun.transform.position = OffHandPos.transform.position;
            MineralVacuum.transform.position = OnHandPos.transform.position;
            PlayerGun.transform.rotation = OffHandPos.transform.rotation;
            MineralVacuum.transform.rotation = OnHandPos.transform.rotation;
        }
        else
        {
            PlayerGun.transform.position = OnHandPos.transform.position;
            MineralVacuum.transform.position = OffHandPos.transform.position;
            PlayerGun.transform.rotation = OnHandPos.transform.rotation;
            MineralVacuum.transform.rotation = OffHandPos.transform.rotation;
        }
    }

    private void CalculateWaterFuelPercentage()
    {
        WaterFuelPercentage = CurrentWaterFuelAmount / MaxWaterFuelAmount;
    }

    private void SuckMineralFuel()
    {
        if (CurrentOutcrop != null)
        {
            if (CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop > 0)
            {
                CurrentOutcrop.GetComponent<OutcropScript>().FuelInOutcrop -= SuckSpeed;
                RaftFuelHolding += SuckSpeed;
            }
        }
    }
}

