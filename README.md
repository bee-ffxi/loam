# **L**ow **O**verhead **A**ssociative **M**agic

LOAM allows you to put associated lists of spells on a single macro. By initiating the command associated with one such list, LOAM will attempt to cast spells in the specified order until it is able to successfully initiate a cast. This is most useful for elemental ninjutsu and enmity-generating spells, when you want to simply cast whatever spells are available.

### Usage

In the `data/settings` file, specify a sequence name and a sequence of spells as such:
```
<nindrk>
    <1>Stun</1>
    <2>Aspir</2>
    <3>Bind</3>
    <4>Sleep</4>
</nindrk>
```

And call the sequence with the command, `loam sequence nindrk`.

### Elemental Ninjutsu

Elemental Ninjutsu is a special case. You can specify the prioritized order you wish to cast ninjutsu in `data/settings` by listing prefixes under the `<ninjutsu>` tag, such as:

```
<ninjutsu>
    <1>Hyoton</1>
    <2>Suiton</2>
    <3>Huton</3>
    <4>Doton</4>
    <5>Raiton</5>
    <6>Katon</6>
</ninjutsu>
```

and invoke the wheel command with `loam wheel ni` or `loam wheel ichi` to spin the Ni and Ichi wheels, or `loam wheel both` to spin the Ni wheel followed by the Ichi wheel. 