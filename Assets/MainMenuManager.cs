using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenuManager : MonoBehaviour
{
    private void Start()
    {
        Cursor.visible = true;
    }

    public void LoadMainScene()
    {
        SceneManager.LoadScene("MainScene");
    }
}
