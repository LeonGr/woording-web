<style lang="sass" scoped>
.language-name-container {
    display: flex;
    .language-name {
        flex: 1;
    }
}

$border-style: 0.125rem solid #B6B6B6;
#translation-list {
    color: #212121;
    display: flex;
    min-height: 0px;

    #delete-translation {
        background: #EEE;
        border-top-right-radius: 3px;
        border-bottom-right-radius: 3px;
        border: 1px solid #DDD;
        padding: 10px;
        font-weight: 400;
        cursor: pointer;
    }

    .translation-record {
        width: 100%;
        display: flex;
        padding-left: .5rem;
        padding-right: .5rem;
        padding: 0.5rem;

        .list-item {
            flex: 1;
            padding: 0.25rem;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 3px;

            &:not(:last-child):nth-child(odd) {
                margin-right: 0.5rem;
            }

            &:nth-child(even) {
                border-top-right-radius: 0;
                border-bottom-right-radius: 0;
                border-right: none;
            }
        }
    }

    .list-header {
        width: 100%;

        padding: .5rem .5rem 0 .5rem;
        input {
            border-radius: 5px;
            border: 1px solid #ccc;
            padding: 3px;
            font-size: 1rem;
            color: #FF9800;
            font-weight: normal;
            width: 100%;
        }

        h2 {
            font-size: 1.2rem;
            color: #212121;
        }

        .language-name-container {
            display: flex;
            .language-name {
                flex: 1;
                &:last-child {
                    margin-left: 10px;
                }
                select {
                    width: 100%;
                    background: white;
                    border-radius: 3px;
                    padding: 3px;
                }
            }

            border-bottom: $border-style;
            padding: 0.25rem;
        }
    }
}

#translation-list {
    .container {
        flex: 1;

        button {
            background: white;
            color: black;
            padding: 5px;
            /*width: 10rem;*/
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 3px;
            cursor: pointer;
            transition: background 0.3s;
            &:hover {
                background: #ccc;
            }
        }

        select {
            background: white;
            border-radius: 3px;
        }

        input[type=checkbox] {
            color: white;
        }
    }

    flex: 1;
    @media(min-width: 768px) {
        overflow: auto;
    }
}
</style>

<template>
<div id="translation-list">
    <div class="container">
        <div class="list-header">
            List name: <input type="text" placeholder="Listname" v-model='listname' value="{{ list.listname }}" maxlength="20">

            <div class="language-name-container">
                <div class="language-name">
                    Language one: <select name="language_1_tag" v-model="language_1_tag">
                        <option value="eng">Eng</option>
                        <option value="dut">Dut</option>
                        <option value="ger">Ger</option>
                    </select>
                </div>

                <div class="language-name">
                    Language two: <select name="language_2_tag" v-model="language_2_tag">
                        <option value="eng">Eng</option>
                        <option value="dut">Dut</option>
                        <option value="ger">Ger</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="translation-record" v-for="word in list.words">
            <input type="text" value="{{ word.language_1_text }}" placeholder="sentence" class="sentence-item list-item">
            <input type="text" value="{{ word.language_2_text }}" placeholder="translation" class="translation-item list-item" v-on:keyup.tab.prevent="newTabRow" name="edit_input">
            <div v-on:click="deleteTranslation(word)" id="delete-translation">X</div>
        </div>
        <button v-on:click="addRow">Add Row</button>
        <div id="translation-bottom"></div>

        Shared with <select name="shared_with" v-model="shared_with">
            <option value="0">No one</option>
            <option value="1">Friends</option>
            <option value="2">Everyone</option>
        </select>
        <br>
        Duplicate list <input type="checkbox" v-model='duplicate'>
        <br><br>
        <button v-on:click="saveList">Save list</button>
        <span>{{ error }}</span>
    </div>
</div>
</template>

<script>
import store from '../../store'
import globals from '../../globals'

export default {
    data: function(){
        return {
            list: {},
            listname : '',
            oldname: '',
            error: '',
            duplicate: false,
            language_1_tag: '',
            language_2_tag: '',
            shared_with: ''
        }
    },

    route: {
        data () {
            var username = this.$parent.$route.params.username
            var listname = this.$parent.$route.params.listname

            if(listname){
                var updateList = list => {
                    this.list = list
                    this.listname = list.listname
                    this.oldname = list.listname
                    this.language_1_tag = list.language_1_tag
                    this.language_2_tag = list.language_2_tag
                    this.shared_with = list.shared_with
                }

                store.fetchList(username, listname).then((list) => {
                    updateList(list)
                })
            }
            else if (store.importedWords){
                this.list = {
                    listname: '',
                    language_1_tag: 'dut',
                    language_2_tag: 'eng',
                    shared_with: '1',
                    words: store.importedWords
                }
            }
            else {
                this.list = {
                    listname: '',
                    language_1_tag: 'dut',
                    language_2_tag: 'eng',
                    shared_with: '1',
                    words: [
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''},
                        {language_1_text: '', language_2_text: ''}
                    ]
                }
            }
        }
    },

    methods: {
        addRow: function() {
            // Create new empty row
            this.list.words.push({language_1_text: '', language_2_text: ''})
        },

        newTabRow: function(e) {
            // If there is no row below current row create a new one
            if(!e.target.parentElement.nextSibling.innerHTML){
                this.addRow()
            }
        },

        deleteTranslation: function(translation){
            this.list.words.$remove(translation)
        },

        saveList: function() {
            var words = []

            var sentences = document.getElementsByClassName('sentence-item')
            var translations = document.getElementsByClassName('translation-item');

            // Add all words from form into words array
            for (var i = 0; i < sentences.length; i++) {
                words.push({
                    language_1_text: sentences[i].value,
                    language_2_text: translations[i].value
                })
            };

            // Stop function when listname is empty
            if (!this.listname){
                this.error = 'Could not save list: Listname should not be empty.'
                return false
            }

            globals.validateInput(this.listname).then(response => {
                console.log(response)
                // Create new list data from form
                var list_data = {
                    listname: this.listname,
                    language_1_tag: this.language_1_tag,
                    language_2_tag: this.language_2_tag,
                    shared_with: this.shared_with,
                    words: words
                }

                // Check if listname changed and user doesn't want to duplicate it. Also checks if listname was empty (new list)
                if (this.listname != this.list.listname && this.listname && !this.duplicate && this.list.listname){
                    store.deleteList(store.username, this.list).then((response) => {
                        console.log(response)
                    })
                }

                // Call savelist in store and after that show the new/edited list
                store.saveList(store.username, list_data).then((response) => {
                    console.log(response)
                    console.timeEnd('savelist')
                    if(response.response == "List exists" && this.oldname != this.listname){
                        if(!confirm('There is already a list with this name, do you want to continue and delete the old list?')){
                            list_data.listname = this.oldname
                            store.saveList(store.username, list_data).then(response => {
                                console.log('Undo')
                            })
                            list_data = {
                                listname: response.old_list.listname,
                                language_1_tag: response.old_list.language_1_tag,
                                language_2_tag: response.old_list.language_2_tag,
                                shared_with: response.old_list.shared_with,
                                words: response.old_words
                            }
                            store.saveList(store.username, list_data).then(response => {
                                console.log('Undo')
                            })
                            // Go back to old list when people don't want to overwrite
                            this.$parent.$route.router.go({ path: '/' + store.username + '/' + this.oldname })
                        }
                        else {
                            // Go to new list when people overwrite
                            this.$parent.$route.router.go({ path: '/' + store.username + '/' + response.old_list.listname })
                        }
                    }
                    else if (response.response == "List exists"){
                        // Only list edited and not listname so go back to same list
                        this.$parent.$route.router.go({ path: '/' + store.username + '/' + response.old_list.listname })
                    }

                    else {
                        // Go to new list name
                        this.$parent.$route.router.go({ path: '/' + store.username + '/' + response.listname })
                    }

                    this.list = list_data
                }).catch(error => {
                    console.log('error')
                    console.log(error)
                })
            }).catch(error => {
                this.error = 'List not saved, reason: Illegal character used. \nPlease only use letters, numbers, spaces and hyphen'
                alert(this.error)
                console.log(error)
            })
        }
    }
}
</script>
