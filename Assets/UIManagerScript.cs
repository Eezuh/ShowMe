using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIManagerScript : MonoBehaviour
{
    public GameObject PlayerStatObject;
    public GameObject RaftStatObject;

    public Image VacuumFill;
    public Image GunFill;
    public Image RaftFill;
    public Image HealthFill;

    private void Update()
    {
        HealthFill.fillAmount = PlayerStatObject.GetComponent<CharacterScript>().health / PlayerStatObject.GetComponent<CharacterScript>().maxHealth;
        GunFill.fillAmount = PlayerStatObject.GetComponent<CharacterScript>().CurrentWaterFuelAmount / PlayerStatObject.GetComponent<CharacterScript>().MaxWaterFuelAmount;
        RaftFill.fillAmount = RaftStatObject.GetComponent<RaftController>().fuel / RaftStatObject.GetComponent<RaftController>().maxFuel;
        VacuumFill.fillAmount = 1 - (PlayerStatObject.GetComponent<CharacterScript>().RaftFuelHolding / PlayerStatObject.GetComponent<CharacterScript>().MaxRaftFuelHolding);
    }
}
